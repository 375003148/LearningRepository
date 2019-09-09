//
//  ViewController.m
//  GCD
//
//  Created by 周子和 on 2019/9/5.
//  Copyright © 2019年 周子和. All rights reserved.
//

/*
 *重点 : 区分同步和异步,串行队列和并发队列的概念和区别
 异步是有开启新线程的能力的,但是不一定开启, 并发队列也不一定,异步并发时才开启新线程,同步并发还是在当前的前程, 但是任务很多时线程会回收重用,不会开启很多
 */

/*
 GCD(Grand Central Diapatch)是纯C语言开发的一组强大的实现多线程的API;
 优势:
 GCD 可用于多核的并行运算
 GCD 会自动利用更多的 CPU 内核（比如双核、四核）
 GCD 会自动管理线程的生命周期（创建线程、调度任务、销毁线程）
 程序员只需要告诉 GCD 想要执行什么任务，不需要编写任何线程管理代码
 
 
 学习 GCD 之前，先来了解 GCD 中两个核心概念：任务和队列。
 任务：就是执行操作的意思，换句话说就是你在线程中执行的那段代码。在 GCD 中是放在 block 中的。执行任务有两种方式：同步执行（sync）和异步执行（async）。两者的主要区别是：是否等待队列的任务执行结束，以及是否具备开启新线程的能力。
 
 同步执行（sync）：
 同步添加任务到指定的队列中，在添加的任务执行结束之前，会一直等待，直到队列里面的任务完成之后再继续执行。
 只能在当前线程中执行任务，不具备开启新线程的能力。
 
 异步执行（async）：
 异步添加任务到指定的队列中，它不会做任何等待，可以继续执行任务。
 可以在新的线程中执行任务，具备开启新线程的能力。
 
 在 GCD 中有两种队列：串行队列和并发队列。两者都符合 FIFO（先进先出）的原则。两者的主要区别是：执行顺序不同，以及开启线程数不同。
 
 串行队列（Serial Dispatch Queue）：
 每次只有一个任务被执行。让任务一个接着一个地执行。（只开启一个线程，一个任务执行完毕后，再执行下一个任务）
 
 并发队列（Concurrent Dispatch Queue）：
 可以让多个任务并发（同时）执行。（可以开启多个线程，并且同时执行任务）
 
 
 线程生命周期：
 新建状态：在内存中，但不在可调度池
 就绪状态：在可调度池中，可以执行任务
 运行状态：在可调度池中，正在执行任务
 阻塞状态：被移出可调度池，在内存中，不能执行任务
 死亡状态：被释放
 
 主队列对应主线程,其它串行队列对应其它线程
 */


#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    异步+并发队列
//    [self asyncConcurrent];
//    异步+串行队列
//    [self asyncSerial];
//     同步+并发队列
//    [self syncConcurrent];
//     同步+串行队列
//    [self syncSerial];
    
    
    //延迟调用
//    [self dispatchAfter];
    //信号量 dispatch_semaphore锁
//    [self dispatch_semaphore_lock];
    
    //使用dispatch_semaphore模拟多个网络请求的场景
//    [self dispatch_semaphore_network];
    //dispatch_group模拟多个网络请求加载完成之后再更新UI
//    [self dispatch_group_network];
    
    
}

// 异步+并发队列
/*
 * 此场景会开启多线程(当然不包含主线程)执行各个任务,任务完成的顺序也是随机的但是任务很多的时候线程数也会达到一定上线,开启的线程会复用.
 */
- (void)asyncConcurrent {
    //创建并发队列
    dispatch_queue_t concurrentQueue = dispatch_queue_create("com.zzh.concurrent", DISPATCH_QUEUE_CONCURRENT);
    //异步调用
    dispatch_async(concurrentQueue, ^{
        NSLog(@"任务1, 线程----%@", [NSThread currentThread]);
    });
    dispatch_async(concurrentQueue, ^{
        NSLog(@"任务2, 线程----%@", [NSThread currentThread]);
    });
    dispatch_async(concurrentQueue, ^{
        NSLog(@"任务3, 线程----%@", [NSThread currentThread]);
    });
}

// 异步+串行队列
/*
 * 此场景会直接开启一个线程串行地顺序执行所有任务
 * 特殊情况:异步+主队, 则不会再有新的线程开启
 */
- (void)asyncSerial {
    //创建串行队列
    dispatch_queue_t serialQueue = dispatch_queue_create("com.zzh.serial", DISPATCH_QUEUE_SERIAL);
    //异步调用
    dispatch_async(serialQueue, ^{
        sleep(4);
        NSLog(@"任务1, 线程----%@", [NSThread currentThread]);
    });
    dispatch_async(serialQueue, ^{
        sleep(2);
        NSLog(@"任务2, 线程----%@", [NSThread currentThread]);
    });
    dispatch_async(serialQueue, ^{
        NSLog(@"任务3, 线程----%@", [NSThread currentThread]);
    });
}

// 同步+并发队列
/*
 *  此场景下任务都在主线程中执行, 并没有开启新的线程.
    也不是说所有的同步执行的操作都在主线程中执行,而是在哪个线程执行的同步并发操作,就在当前线程执行任务.
 */
- (void)syncConcurrent {
    //创建并发队列
    dispatch_queue_t concurrentQueue = dispatch_queue_create("com.zzh.concurrent", DISPATCH_QUEUE_CONCURRENT);
    //同步调用
    dispatch_sync(concurrentQueue, ^{
        sleep(5);
        NSLog(@"任务1, 线程----%@", [NSThread currentThread]);
    });
    dispatch_sync(concurrentQueue, ^{
        NSLog(@"任务2, 线程----%@", [NSThread currentThread]);
    });
    dispatch_sync(concurrentQueue, ^{
        NSLog(@"任务3, 线程----%@", [NSThread currentThread]);
    });
}

// 同步+串行队列
/*
 *  此场景下任务都在主线程中执行, 并没有开启新的线程.如果在子线程执行这段代码,则在这个子线程执行任务,也不会再开启别的线程
 *  需要记住的就是, 同步执行并没有开启子线程的能力, 所有的操作, 都是在当前线程执行.
 *  注意:同步+主队列 则会造成死锁
 */
- (void)syncSerial {
    //创建串行队列
    dispatch_queue_t serialQueue = dispatch_queue_create("com.zzh.serial", DISPATCH_QUEUE_SERIAL);
    //同步调用
    dispatch_async(serialQueue, ^{
        sleep(5);
        NSLog(@"任务1, 线程----%@", [NSThread currentThread]);
    });
    dispatch_async(serialQueue, ^{
        NSLog(@"任务2, 线程----%@", [NSThread currentThread]);
    });
    dispatch_async(serialQueue, ^{
        NSLog(@"任务3, 线程----%@", [NSThread currentThread]);
    });
}

- (void)dispatchAfter {
    //此时会先执行dispatch_after方法前,然后马上执行dispatch_after方法后,然后大概5s后执行任务
    NSLog(@"dispatch_after方法前,线程A---%@", [NSThread currentThread]);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"任务线程---%@", [NSThread currentThread]);
    });
    NSLog(@"dispatch_after方法后");
}

// dispatch_semaphore锁
- (void)dispatch_semaphore_lock {
    //crate的value表示，最多几个资源可访问.  理解为有几个停车位
    //先dispatch_semaphore_wait,信号量-1. 理解为停车位-1
    //任务完成再dispatch_semaphore_signal,信号量+1, ;理解为g停车位+1
    
    //模拟dispatch_semaphore锁, 每次只有一个线程能够访问资源
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    dispatch_queue_t quene = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    [NSThread detachNewThreadWithBlock:^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        NSLog(@"%@,任务1开始", [NSThread currentThread]);
        sleep(5);
        NSLog(@"%@,任务1...", [NSThread currentThread]);
        NSLog(@"%@,任务1结束", [NSThread currentThread]);
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_async(quene, ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        NSLog(@"%@,任务2开始", [NSThread currentThread]);
        sleep(2);
        NSLog(@"%@,任务2...", [NSThread currentThread]);
        NSLog(@"%@,任务2结束", [NSThread currentThread]);
        dispatch_semaphore_signal(semaphore);
    });
    dispatch_async(quene, ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        NSLog(@"%@,任务3开始", [NSThread currentThread]);
        sleep(6);
        NSLog(@"%@,任务3...", [NSThread currentThread]);
        NSLog(@"%@,任务3结束", [NSThread currentThread]);;
        dispatch_semaphore_signal(semaphore);
    });
    dispatch_async(quene, ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        NSLog(@"%@,任务4开始", [NSThread currentThread]);
        sleep(4);
        NSLog(@"%@,任务4...", [NSThread currentThread]);
        NSLog(@"%@,任务4结束", [NSThread currentThread]);
        dispatch_semaphore_signal(semaphore);
    });
}

- (void)dispatch_semaphore_network {
    
    //网络请求会加载完成一个再加载下一个,最后更新UI
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"%@,任务1开始", [NSThread currentThread]);
        sleep(3);
        NSLog(@"%@,任务1结束", [NSThread currentThread]);
        dispatch_semaphore_signal(semaphore);
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"%@,任务2开始", [NSThread currentThread]);
        sleep(5);
        NSLog(@"%@,任务2结束", [NSThread currentThread]);
        dispatch_semaphore_signal(semaphore);
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"%@,更新UI", [NSThread currentThread]);
    });
}

- (void)dispatch_group_network {
    //注意:使用dispatch_group + dispatch_group_notify的方式完全不会a阻塞主线程
    dispatch_group_t group = dispatch_group_create();
    
    //使用dispatch_async模拟AFNetworking的场景
    dispatch_group_enter(group);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"%@,任务1开始", [NSThread currentThread]);
        sleep(2);
        NSLog(@"%@,任务1结束", [NSThread currentThread]);
        dispatch_group_leave(group);
    });
    
    dispatch_group_enter(group);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"%@,任务2开始", [NSThread currentThread]);
        sleep(5);
        NSLog(@"%@,任务2结束", [NSThread currentThread]);
        dispatch_group_leave(group);
    });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"%@,更新UI", [NSThread currentThread]);
    });
    NSLog(@"主线程的后续活动1");
    NSLog(@"主线程的后续活动2");
    NSLog(@"主线程的后续活动3");
    sleep(1);
    NSLog(@"主线程的后续活动4");
}

@end
