+++
title = "We used to build steel mills near cheap power. Now that's where we build datacenters"
date  = 2015-05-01
[taxonomies]
tags  = ["danluu"]
+++

Why are people so concerned with hardware power consumption nowadays? Some common answers to this question are that [power is critically important for phones, tablets, and laptops](<http://www.vox.com/2015/3/9/8178213/apple-macbook-all-batteries>) and that [we can put more silicon on a modern chip than we can effectively use](<ftp://ftp.cs.utexas.edu/pub/dburger/papers/ISCA11.pdf>). In 2001 [Patrick Gelsinger observed that if scaling continued at then-current rates](<http://ieeexplore.ieee.org/xpl/login.jsp?tp=&arnumber=912412&url=http%3A%2F%2Fieeexplore.ieee.org%2Fxpls%2Fabs_all.jsp%3Farnumber%3D912412>), chips would have the power density of a nuclear reactor by 2005, a rocket nozzle by 2010, and the surface of the sun by 2015, implying that power density couldn't continue on its then-current path. Although this was already fairly obvious at the time, now that it's 2015, we can be extra sure that power density didn't continue to grow at unbounded rates. Anyway, the importance of portables and scaling limits are both valid and important reasons, but since they're widely discussed, I'm going to talk about an underrated reason.

People often focus on the portable market because it's cannibalizing desktop market, but that's not the only growth market -- servers are also becoming more important than desktops, and power is really important for servers. To see why power is important for servers, let's look at some calculations about how what it costs to run a datacenter from [Hennessy & Patterson](<http://www.amazon.com/gp/product/012383872X/ref=as_li_qf_sp_asin_il_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=012383872X&linkCode=as2&tag=abroaview-20&linkId=Y6Z2OBCUCR72ALEB>).

One of the issues is that you pay for power multiple times. Some power is lost at the substation, although we might not have to pay for that directly. Then we lose more storing energy in a UPS. This figure below states 6%, but smaller scale datacenters can easily lose twice that. After that, we lose more power stepping down the power to a voltage that a server can accept. That's over a 10% loss for a setup that's pretty efficient.

After that, we lose more power in the server's power supply, stepping down the voltage to levels that are useful inside a computer, which is often about another 10% loss (not pictured in the figure below).

![Power conversion figure from Hennessy & Patterson, which reproduced the figure from Hamilton](https://danluu.com/images/datacenter-power/power_conversion.png)

And then once we get the power into servers, it gets turned into waste heat. To keep the servers from melting, we have to pay for power to cool them. [Barroso and Holzle](<http://www.morganclaypool.com/doi/abs/10.2200/S00193ED1V01Y200905CAC006>) estimated that 30%-50% of the power drawn by a datacenter is used for chillers, and that an additional 10%-20% is for the [CRAC](<http://www.dchuddle.com/2011/crac-v-crah/>) (air circulation). That means for every watt of power used in the server, we pay for another 1-2 watts of support power.

And to actually get all this power, we have to pay for the infrastructure required to get the power into and throughout the datacenter. Hennessy & Patterson estimate that of the $90M cost of an example datacenter (just the facilities -- not the servers), 82% is associated with power and cooling1. The servers in the datacenter are estimated to only cost $70M. It's not fair to compare those numbers directly since servers need to get replaced more often than datacenters; once you take into account the cost over the entire lifetime of the datacenter, the amortized cost of power and cooling comes out to be 33% of the total cost, when servers have a 3 year lifetime and infrastructure has a 10-15 year lifetime.

If we look at all the costs, the breakdown is:

category| %  
---|---  
server machines| 53  
power & cooling infra| 20  
power use| 13  
networking| 8  
other infra| 4  
humans| 2  
  
Power use and people are the cost of operating the datacenter (OPEX), whereas server machines, networking, power & cooling infra, and other infra are capital expenditures that are amortized across the lifetime of the datacenter (CAPEX).

Computation uses a lot of power. [We used to build steel mills near cheap sources of power](<http://www.datacenterknowledge.com/archives/2010/05/19/microsoft-building-new-data-center-in-quincy/>), but [now that's where we build datacenters](<http://www.datacenterknowledge.com/archives/2010/05/19/microsoft-building-new-data-center-in-quincy/>). As companies start considering the full cost of applications, we're seeing a lot more power optimized solutions2. Unfortunately, this is really hard. On the software side, with the exceptions of toy microbenchmark examples, [best practices for writing power efficient code still aren't well understood](<http://arcade.cs.columbia.edu/energy-oopsla14.pdf>). On the hardware side, Intel recently released a new generation of chips with significantly improved performance per watt that doesn't have much better absolute performance than the previous generation. On the hardware accelerator front, some large companies are building dedicated power-efficient hardware for specific computations. But with existing tools, hardware accelerators are costly enough that dedicated hardware only makes sense for the largest companies. There isn't an easy answer to this problem.

If you liked this post, you'd probably like chapter 6 of [Hennessy & Patterson](<http://www.amazon.com/gp/product/012383872X/ref=as_li_qf_sp_asin_il_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=012383872X&linkCode=as2&tag=abroaview-20&linkId=Y6Z2OBCUCR72ALEB>), which walks through not only the cost of power, but a number of related back of the envelope calculations relating to datacenter performance and cost.

Apologies for the quickly scribbled down post. I jotted this down shortly before signing an NDA for an interview where I expected to learn some related information and I wanted to make sure I had my thoughts written down before there was any possibility of being contaminated with information that's under NDA.

Thanks to Justin Blank for comments/corrections/discussion. 

* * *

  1. Although this figure is widely cited, I'm unsure about the original source. This is probably the most suspicious figure in this entire post. Hennessy & Patterson cite “Hamilton 2010”, which appears to be a reference to [this presentation](<http://mvdirona.com/jrh/TalksAndPapers/JamesHamilton_GenomicsCloud20100608.pdf>). That presentation doesn't make the source of the number obvious, although [this post by Hamilton does cite a reference for that figure](<http://perspectives.mvdirona.com/2008/11/cost-of-power-in-large-scale-data-centers/>), but the citation points to [this post](<http://blogs.msdn.com/b/the_power_of_software/archive/2008/09/19/intense-computing-or-in-tents-computing.aspx>), which seems to be about putting datacenters in tents, not the fraction of infrastructure that's dedicated to power and cooling.

Some other works, [such as this one](<http://science.energy.gov/~/media/ascr/ascac/pdf/meetings/mar09/Reed.pdf>) cite [this article](<http://www.electronics-cooling.com/2007/02/in-the-data-center-power-and-cooling-costs-more-than-the-it-equipment-it-supports/>). However, that article doesn't directly state 82% anywhere, and it makes a number of estimates that the authors acknowledge are very rough, with qualifiers like “While, admittedly, the authors state that there is a large error band around this equation, it is very useful in capturing the magnitude of infrastructure cost.”

[return]
  2. That being said, power isn't everything -- Reddi et al. looked at replacing conventional chips with low-power chips for a real workload (MS Bing) and found that while they got an improvement in power use per query, tail latency increased significantly, especially when servers were heavily loaded. Since Bing has a mechanism that causes query-related computations to terminate early if latency thresholds are hit, the result is both higher latency and degraded search quality. [return]


[← Advantages of monorepos](<https://danluu.com/monorepo/>) [Reading citations is easier than most people think →](<https://danluu.com/dunning-kruger/>)
