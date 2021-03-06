---
layout: post
title: "分析linux内核的idle的知识 "
date: 2010-10-16 14:24
comments: true
categories: Linux
tags: Linux 内核
---
<p>Linux系统越来越受到电脑用户的欢迎，于是很多人开始学习Linux时，学习linux，你可能会遇到linux内核问题，这里将介绍linux内核中idle知识，
在这里拿出来和大家分享一下。</p>

<h2>1. idle是什么</h2>
<p>简单的说idle是一个进程，其pid号为 0。其前身是系统创建的第一个进程，也是唯一一个没有通过fork()产生的进程。在smp系统中，每个处理器单元有
独立的一个运行队列，而每个运行队列上又有一个idle进程，即有多少处理器单元，就有多少idle进程。系统的空闲时间，其实就是指idle进程的"运行时间"。
既然是idle是进程，那我们来看看idle是如何被创建，又具体做了哪些事情?</p>

<!--more-->

<h2>2. idle的创建</h2>
<p>我们知道系统是从BIOS加电自检，载入MBR中的引导程序(LILO/GRUB),再加载linux内核开始运行的，一直到指定shell开始运行告一段落，这时用户开始操作Linux。
而大致是在vmlinux的入口startup_32(head.S)中为pid号为0的原始进程设置了执行环境，然后原是进程开始执行start_kernel()完成Linux内核的初始化工作。包括
初始化页表，初始化中断向量表，初始化系统时间等。继而调用 fork(),创建第一个用户进程:</p>
{% codeblock lang:c %}
　　kernel_thread(kernel_init, NULL, CLONE_FS | CLONE_SIGHAND);
{% endcodeblock %}

<p>这个进程就是着名的pid为1的init进程，它会继续完成剩下的初始化工作，然后execve(/sbin/init), 成为系统中的其他所有进程的祖先。关于init我们这次先不研究，
回过头来看pid=0的进程，在创建了init进程后，pid=0的进程调用 cpu_idle()演变成了idle进程。</p>
{% codeblock lang:c %}
　　current_thread_info()->status |= TS_POLLING;
{% endcodeblock %}

<p>在 smp系统中，除了上面刚才我们讲的主处理器(执行初始化工作的处理器)上idle进程的创建，还有从处理器(被主处理器activate的处理器)上的idle进程，他们又是
怎么创建的呢?接着看init进程，init在演变成/sbin/init之前，会执行一部分初始化工作，其中一个就是 smp_prepare_cpus()，初始化SMP处理器，在这过程中会在处理
每个从处理器时调用</p>
{% codeblock lang:c %}
　　task = copy_process(CLONE_VM, 0, idle_regs(?s), 0, NULL, NULL, 0);
　　init_idle(task, cpu);
{% endcodeblock %}

<p>即从init中复制出一个进程，并把它初始化为idle进程(pid仍然为0)。从处理器上的idle进程会进行一些Activate工作，然后执行cpu_idle()。</p>

<p>整个过程简单的说就是，原始进程(pid=0)创建init进程(pid=1),然后演化成idle进程(pid=0)。init进程为每个从处理器(运行队列)创建出一个idle进程(pid=0)，
然后演化成/sbin/init。</p>

<h2>3. idle的运行时机</h2>
<p>idle 进程优先级为MAX_PRIO，即最低优先级。早先版本中，idle是参与调度的，所以将其优先级设为最低，当没有其他进程可以运行时，才会调度执行idle。
而目前的版本中idle并不在运行队列中参与调度，而是在运行队列结构中含idle指针，指向idle进程，在调度器发现运行队列为空的时候运行，调入运行。</p>

<h2>4. idle的workload</h2>
<p>从上面的分析我们可以看出，idle在系统没有其他就绪的进程可执行的时候才会被调度。不管是主处理器，还是从处理器，最后都是执行的cpu_idle()函数。
所以我们来看看cpu_idle做了什么事情。</p>

<p>因为idle进程中并不执行什么有意义的任务，所以通常考虑的是两点：1.节能，2.低退出延迟。</p>

<p>其核心代码如下：</p>
{% codeblock lang:c %}
void cpu_idle(void) {
	int cpu = smp_processor_id();
	current_thread_info()->status |= TS_POLLING;   /* endless idle loop with no priority at all */
	while (1) {
		tick_nohz_stop_sched_tick(1);
		while (!need_resched()) {
			check_pgt_cache();
			rmb();
			if (rcu_pending(cpu))  rcu_check_callbacks(cpu, 0);
			if (cpu_is_offline(cpu))  play_dead();
			local_irq_disable();
			__get_cpu_var(irq_stat).idle_timestamp = jiffies; /* Don't trace irqs off for idle */
			stop_critical_timings();
			pm_idle();
			start_critical_timings();
		}
		tick_nohz_restart_sched_tick();
		preempt_enable_no_resched();
		schedule();
		preempt_disable();
	}
}
{% endcodeblock %}

<p>循环判断need_resched以降低退出延迟，用idle()来节能。</p>

<p>默认的idle实现是hlt指令，hlt指令使CPU处于暂停状态，等待硬件中断发生的时候恢复，从而达到节能的目的。即从处理器C0态变到C1态(见 ACPI标准)。这
也是早些年windows平台上各种"处理器降温"工具的主要手段。当然idle也可以是在别的ACPI或者APM模块中定义的，甚至是自定义的一个idle(比如说nop)。</p>

<p>注：本文转自http://www.builder.com.cn/2010/1011/1908337.shtml</p>