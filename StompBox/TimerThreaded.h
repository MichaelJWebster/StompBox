//
//  TimerThreaded.hpp
//  TimerPool
//
//  Created by Michael Webster on 22/02/2015.
//  Copyright (c) 2015 Mike Webster Ltd. All rights reserved.
//
#ifndef TimerPool_TimerThreaded_hpp
#define TimerPool_TimerThreaded_hpp

#ifdef __cplusplus
extern "C"
{
#endif
#include <mach/mach.h>
#include <mach/mach_time.h>
#include <pthread.h>
#ifdef __cplusplus
};
#endif

class TimerThreaded
{
public:
    static const uint64_t NANOS_PER_USEC;
    static const uint64_t NANOS_PER_MILLISEC;
    static const uint64_t NANOS_PER_SEC;
    
    /**
     * @brief Move a p thread to realtime scheduling.
     */
    static void moveToRealTime(pthread_t pthread);
    
    /*
    * NOTE: mach_timebase_info_data_t is a struct like this:
    *
    * struct
    * {
    *      uint32_t numer;    // number of nanoseconds in a second.
    *      uint32_t denom;    // frequency of ticks per second.
    * } blah...;
    *
    * So
    *
    */
    //static mach_timebase_info_data_t timebase_info;

    
    /**
     * @brief Convert a time in absolute ticks into a nano second value.
     */
    static uint64_t abs_to_nanos(uint64_t abs);
    
    /**
     * @brief Convert a nanosecond time into clock ticks.
     */
    static uint64_t nanos_to_abs(uint64_t nanos);

    TimerThreaded();
    ~TimerThreaded();

    /**
     * @brief Get the wait time.
     */
    uint64_t getWaitTime() const;
    
    /**
     * @brief Set the wait time.
     */
    void setWaitTime(uint64_t wt);
    
    /**
     * @brief Set the wait time.
     */
    void setWaitTimeMs(uint64_t wt);
    
    /**
     * @brief Get the number of ticks.
     */
    uint32_t getTicks() const;
    
    /**
     * @brief Tick the clock.
     */
    void tick();
    
    /**
     * @brief Get the timer's mutex.
     */
    pthread_mutex_t &getMutex();
    
    /**
     * @brief Lock the mutex
     */
    void mutexLock();
    
    /**
     * @brief UnLock the mutex
     */
    void mutexUnLock();
    
    /**
     * @brief Setup the timer.
     */
    void setTimer();
    
    /**
     * @brief Start the timer.
     */
    void startTimer();
    
    /**
     * @brief Stop the timer.
     */
    void stopTimer();
    
    /**
     * @brief The timer thread's main loop.
     */
    static void *timerThreaded(void *data);
    
    /**
     * @brief is the timer killed?
     */
    bool isKilled() const;
    
    void kill();
private:
    
    /**
     * @brief Has the time base been initialized.
     */
    static bool time_base_initialized;
    
    /**
     * @brief kill the timer.
     */
     
    bool fKill;

    /**
     * @brief This value contains the wait time for the next loop.
     */
    uint64_t fNanoWaitTime;
    
    /**
     * @brief This value contains the next wait time for the timer
     */
    uint64_t fNextWaitTime;
    
    /**
     * @brief The number of ticks for this clock.
     */
    uint32_t fNumTicks;
    
    /**
     * @brief The pthread for this timer.
     */
    pthread_t fPthread;

    /**
     * @brief The mutex for this timer.
     */
    pthread_mutex_t fTimerMutex;
};

#endif
