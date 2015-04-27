//
//  TimerThreaded.cpp
//  TimerPool
//
//  Created by Michael Webster on 22/02/2015.
//  Copyright (c) 2015 Mike Webster Ltd. All rights reserved.
//
#include "TimerThreaded.h"

extern "C"
{
#include <stdlib.h>
#include <assert.h>
#include <stdio.h>
#include <unistd.h>
};

const uint64_t TimerThreaded::NANOS_PER_USEC = 1000ULL;
const uint64_t TimerThreaded::NANOS_PER_MILLISEC = 1000ULL * NANOS_PER_USEC;
const uint64_t TimerThreaded::NANOS_PER_SEC = 1000ULL * NANOS_PER_MILLISEC;
bool TimerThreaded::time_base_initialized = false;

static mach_timebase_info_data_t fTimeBaseInfo;

TimerThreaded::TimerThreaded()
    :
    fKill(false),
    fNanoWaitTime(0),
    fNextWaitTime(NANOS_PER_SEC),
    fNumTicks(0),
    fPthread(NULL),
    fTimerMutex(PTHREAD_MUTEX_INITIALIZER)
{
    if (!time_base_initialized)
    {
        mach_timebase_info(&fTimeBaseInfo);
        time_base_initialized = true;
    }
}

// Don't think there's anything to do here.
TimerThreaded::~TimerThreaded()
{
}

/**
 * Move pthread to real time scheduling iOS/OSX.
 *
 * @param pthread   The posix thread to be moved.
 */
void TimerThreaded::moveToRealTime(pthread_t pthread)
{
    
    const uint64_t NANOS_PER_MSEC = 1000000ULL;
    double clock2abs =
    (
     (double)fTimeBaseInfo.denom /
     (double)fTimeBaseInfo.numer
     )
    *
    NANOS_PER_MSEC;
    
    thread_time_constraint_policy_data_t policy;
    policy.period      = 0;
    policy.computation = (uint32_t)(5 * clock2abs); // 5 ms of work
    policy.constraint  = (uint32_t)(10 * clock2abs);
    policy.preemptible = FALSE;
    
    int kr = thread_policy_set
    (
        pthread_mach_thread_np
        (pthread_self()),
        THREAD_TIME_CONSTRAINT_POLICY,
        (thread_policy_t)&policy,
        THREAD_TIME_CONSTRAINT_POLICY_COUNT
     );
    
    if (kr != KERN_SUCCESS)
    {
        mach_error("thread_policy_set:", kr);
        exit(1);
    }
}

/**
 * Convert a time in absolute ticks into a nano second value.
 */
uint64_t TimerThreaded::abs_to_nanos(uint64_t abs)
{
    return abs * fTimeBaseInfo.numer / fTimeBaseInfo.denom;
}

/**
 * Convert a nanosecond time into clock ticks.
 */
uint64_t TimerThreaded::nanos_to_abs(uint64_t nanos)
{
    return nanos * fTimeBaseInfo.denom / fTimeBaseInfo.numer;
}

/**
 * @brief Get the wait time.
 */
uint64_t TimerThreaded::getWaitTime() const
{
    return fNanoWaitTime;
}

/**
 * @brief Set the wait time.
 */
void TimerThreaded::setWaitTime(uint64_t wt)
{
        //fNanoWaitTime = wt;
    fNextWaitTime = wt;
}

/**
 * @brief Set the wait time.
 */
void TimerThreaded::setWaitTimeMs(uint64_t wt)
{
    //fNanoWaitTime = wt;
    fNextWaitTime = 1000 * 1000 * wt;
}


/**
 * @brief Get the number of ticks.
 */
uint32_t TimerThreaded::getTicks() const
{
    return fNumTicks;
}

/**
 * @brief tick the clock.
 */
void TimerThreaded::tick()
{
    fNumTicks++;
}

/**
 * @brief Get the timer's mutex.
 */
pthread_mutex_t &TimerThreaded::getMutex()
{
    return fTimerMutex;
}

/**
 * Lock the mutex
 */
void TimerThreaded::mutexLock()
{
    pthread_mutex_lock(&fTimerMutex);
}

/**
 * UnLock the mutex
 */
void TimerThreaded::mutexUnLock()
{
    pthread_mutex_unlock(&fTimerMutex);
}

/**
 * @brief Start the timer.
 */
void TimerThreaded::setTimer()
{
    //pthread_mutex_init(timerMutex, NULL);
    // Create the thread using POSIX routines.
    pthread_attr_t  attr;
    int             returnVal;
    
    returnVal = pthread_attr_init(&attr);
    assert(!returnVal);
    returnVal = pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
    assert(!returnVal);
    void *pThreadData = (void *)this;
    int threadError = pthread_create
    (
        &fPthread,
        &attr,
        &TimerThreaded::timerThreaded,
        pThreadData
     );
    
    returnVal = pthread_attr_destroy(&attr);
    assert(!returnVal);
    if (threadError != 0)
    {
        printf("Error in pthread_create.\n");
    }
    moveToRealTime(fPthread);
    mutexUnLock();
}

void TimerThreaded::startTimer()
{
    fNanoWaitTime = fNextWaitTime;
}

/**
 * @brief Stop the timer.
 */
void TimerThreaded::stopTimer()
{
    fNanoWaitTime = 0;
}

bool TimerThreaded::isKilled() const
{
    return fKill;
}

void TimerThreaded::kill()
{
    fKill = true;
}

/**
 * @brief The timer thread's main loop.
 */
void *TimerThreaded::timerThreaded(void *data)
{
    TimerThreaded *parent = (TimerThreaded *)data;
    // Take the timeMutex;
    //parent->mutexLock();
    uint64_t now = mach_absolute_time();
    while (!parent->isKilled())
    {
        while (parent->getWaitTime() != 0)
        {
            NSLog(@"Wait time in TimerThreaded is: %llu", parent->getWaitTime());
            NSLog(@"BPM is: %llu", 60 * NANOS_PER_SEC / parent->getWaitTime());
            uint64_t time_to_wait = nanos_to_abs(parent->getWaitTime());
            mach_wait_until(now + time_to_wait);
            now = mach_absolute_time();
            parent->tick();
            parent->mutexUnLock();
        }
        now = mach_absolute_time();
        uint64_t time_to_wait = nanos_to_abs(NANOS_PER_SEC);
        mach_wait_until(now + time_to_wait);
    }
    parent->mutexUnLock();
    return NULL;
}
