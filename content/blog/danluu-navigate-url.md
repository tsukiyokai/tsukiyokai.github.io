+++
title = "What happens when you load a URL?"
date  = 2015-03-01
[taxonomies]
tags  = ["danluu"]
+++

I've been hearing this question a lot lately, and when I do, it reminds me how much I don't know. Here are some questions this question brings to mind.

  1. How does a keyboard work? Why can’t you press an arbitrary combination of three keys at once, except on fancy gaming keyboards? That implies something about how key presses are detected/encoded.
  2. How are keys debounced? Is there some analog logic, or is there a microcontroller in the keyboard that does this, or what? How do membrane switches work?
  3. How is the OS notified of the keypress? I could probably answer this for a 286, but nowadays it's somehow done through x2APIC, right? How does that work?
  4. Also, USB, PS/2, and AT keyboards are different, somehow? How does USB work? And what about laptop keyboards? Is that just a USB connection?
  5. How does a USB connector work? You have this connection that can handle 10Gb/s. That surely won't work if there's any gap at all between the physical doodads that are being connected. How do people design connectors that can withstand tens of thousands of insertions and still maintain their tolerances?
  6. How does the OS tell the program something happened? How does it know which program to talk to?
  7. How does the browser know to try to load a webpage? I guess it sees an "http://" or just assumes that anything with no prefix is a URL?
  8. Assume we don't have the webpage cached, so we have to do DNS queries and stuff.
  9. How does DNS work? How does DNS caching work? Let's assume it isn't cached at anywhere nearby and we have to go find some far away DNS server.
  10. TCP? We establish a connection? Do we do that for DNS or does it have to be UDP?
  11. How does the OS decide if an outgoing connection should be allowed? What if there's a software firewall? How does that work?
  12. For TCP, without TLS/SSL, we can just do slow-start followed by some standard congestion protocol, right? Is there some deeper complexity there?
  13. One level down, how does a network card work?
  14. For what matter, how does the network card know what to do? Is there a memory region we write to that the network card can see or does it just monitor bus transactions directly?
  15. Ok, say there's a memory region. How does that work? How do we write memory?
  16. Some things happen in the CPU/SoC! This is one of the few areas where I know something, so, I'll skip over that. A signal eventually comes out on some pins. What's that signal? Nowadays, people use DDR3, but we didn't always use that protocol. Presumably DDR3 lets us go faster than DDR2, which was faster than DDR, and so on, but why?
  17. And then the signal eventually goes into a DRAM module. As with the CPU, I'm going to mostly ignore what's going on inside, but I'm curious if DRAM modules still either trench capacitors or stacked capacitors, or has this technology moved on?
  18. Going back to our network card, what happens when the signal goes out on the wire? Why do you need a cat5 and not a cat3 cable for 100Mb Ethernet? Is that purely a signal integrity thing or do the cables actually have different wiring?
  19. One level below that the wires are surely long enough that they can act like transmission lines / waveguides. How is termination handled? Is twisted pair sufficient to prevent inductive coupling or is there more fancy stuff going on?
  20. Say we have a local Ethernet connection to a cable modem. How do cable modems work? Isn't cable somehow multiplexed between different customers? How is it possible to get so much bandwidth through a single coax cable?
  21. Going back up a level, the cable connection eventually gets to the ISP. How does the ISP know where to route things? How does internet routing work? Some bits in the header decide the route? How do routing tables get adjusted?
  22. Also, the 8.8.8.8 DNS stuff is anycast, right? How is that different from routing "normal" traffic? Ditto for anything served from a Cloudflare CDN. What do they need to do to prevent route flapping and other badness?
  23. What makes anycast hard enough to do that very few companies use it?
  24. IIRC, the Stanford/Coursera algorithms course mentioned that it's basically a distributed Bellman-Ford calculation. But what prevents someone from putting bogus routes up?
  25. If we can figure out where to go our packets go from our ISP through some edge router, some core routers, another edge router, and then go through their network to get into the “meat” of a datacenter.
  26. What's the difference between core and edge routers?
  27. At some point, our connection ends up going into fiber. How does that happen?
  28. There must be some kind of laser. What kind? How is the signal modulated? Is it WDM or TDM? Is it single-mode or multi-mode fiber?
  29. If it's WDM, how is it muxed/demuxed? It would be pretty weird to have a prism in free space, right? This is the kind of thing an AWG could do. Is that what's actually used?
  30. There must be repeaters between links. How do repeaters work? Do they just boost the signal or do they decode it first to avoid propagating noise? If the latter, there must be DCF between repeaters.
  31. Something that just boosts the signal is the simplest case. How does an EDFA work? Is it basically just running current through doped fiber, or is there something deeper going on there?
  32. Below that level, there's the question of how standard single mode fiber and DCF work.
  33. Why do we need DCF, anyway? I guess it's cheaper to have a combination of standard fiber and DCF than to have fiber with very low dispersion. Why is that?
  34. How does fiber even work? I mean, ok, it's probably a waveguide that uses different dielectrics to keep the light contained, but what's the difference between good fiber and bad fiber?
  35. For example, hasn't fiber changed over the past couple decades to severely reduce PMD? How is that possible? Is that just more precise manufacturing, or is there something else involved?
  36. Before PMD became a problem and was solved, there was decades of work that went into increasing fiber bandwidth, vaugely analogous to the way there was decades of work that went into increasing processor performance but also completely different. What was that work and what were the blockers that work was clearing? You'd have to actually know a good deal about fiber engineering to answer this, and I don't.
  37. Going back up a few levels, we go into a datacenter. What's up there? Our packets go through a switching network to TOR to machine? What's a likely switch topology? [Facebook's](<https://code.facebook.com/posts/360346274145943/introducing-data-center-fabric-the-next-generation-facebook-data-center-network/>) isn't quite something straight out of [Dally and Towles](<http://www.amazon.com/gp/product/0122007514/ref=as_li_qf_sp_asin_il_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0122007514&linkCode=as2&tag=abroaview-20&linkId=DNSHYGZA2USRTHCU>), but it's the kind of thing you could imagine building with that kind of knowledge. It hasn't been long enough since FB published their topology for people to copy them, but is the idea obvious enough that you'd expect it to be independently "copied"?
  38. Wait, is that even right? Should we expect a DNS server to sit somewhere in some datacenter?
  39. In any case, after all this our DNS resolves query to an IP. We establish a connection, and then what?
  40. HTTP GET? How are HTTP 1.0 and 1.1 different? 2.0?
  41. And then we get some files back and the browser has to render them somehow. There's a request for the HTML and also for the CSS and js, and separate requests for images? This must be complicated, since browsers are complicated. I don't have any idea of the complexity of this, so there must be a lot I'm missing.
  42. After the browser renders something, how does it get to the GPU and what does the GPU do?
  43. For 2d graphics, we probably just notify the OS of... something. How does that work?
  44. And how does the OS talk to the GPU? Is there some memory mapped region where you can just paint pixels, or is it more complicated than that?
  45. How does an LCD display work? How does the connection between the monitor and the GPU work?
  46. VGA is probably the simplest possibility. How does that work?
  47. If it's a static site, I guess we're done?
  48. But if the site has ads, isn't that stuff pretty complicated? How do targeted ads and ad auctions work? A bunch of stuff somehow happens in maybe 200ms?


Where I can get answers to this stuff1? That's not a rhetorical question! [I'm really interested in hearing about other resources](<https://twitter.com/danluu>)!

[Alex Gaynor set up a GitHub repo that attempts to answer this entire question](<https://github.com/alex/what-happens-when>). It answers some of the questions, and has answers to some questions it didn't even occur to me to ask, but it's missing answers to the vast majority of these questions.

For high-level answers, here's [Tali Garsiel and Paul Irish on how a browser works](<http://www.html5rocks.com/en/tutorials/internals/howbrowserswork/>) and [Jessica McKellar how the Internet Works](<http://pyvideo.org/video/1677/how-the-internet-works>). For how a simple OS does things, [Xv6](<http://pdos.csail.mit.edu/6.828/2014/xv6.html>) has good explanations. For how Linux works, [Gustavo Duarte has a series of explanations here](<http://duartes.org/gustavo/blog/>)[For TTYs, this article by Linus Akesson is a nice supplement](<http://www.linusakesson.net/programming/tty/index.php>) to Duarte's blog.

One level down from that, [James Marshall has a concise explanation of HTTP 1.0 and 1.1](<http://www.jmarshall.com/easy/http/>), and [SANS has an old but readable guide on SSL and TLS](<http://www.sans.org/reading-room/whitepapers/protocols/ssl-tls-beginners-guide-1029>). [This isn't exactly smooth prose, but this spec for URLs explains in great detail what a URL is](<https://url.spec.whatwg.org/>).

Going down another level, [MS TechNet has an explanation of TCP](<https://technet.microsoft.com/en-us/library/cc786128.aspx>), which also includes a short explanation of UDP.

One more level down, [Kyle Cassidy has a quick primer on Ethernet](<http://www.informit.com/articles/printerfriendly/21320>), [Iljitsch van Beijnum has a lengthier explanation with more history](<http://arstechnica.com/gadgets/2011/07/ethernet-how-does-it-work/>), and [Matthew J Castelli has an explanation of LAN switches](<http://www.ciscopress.com/articles/printerfriendly/357103>). And then we have [DOCSIS and cable modems](<http://support.usr.com/support/6000/6000-ug/two.html>). [This gives a quick sketch of how long haul fiber is set up](<http://www.olson-technology.com/AppNotes/long-haul-communications-systems.pdf>), but there must be a better explanation out there somewhere. And here's [a quick sketch of modern CPUs](<https://danluu.com//danluu.com/new-cpu-features/>). [For an answer to the keyboard specific questions, Simon Inns explains keypress decoding and why you can't press an arbitrary combination of keys on a keyboard](<http://www.waitingforfriday.com/index.php/C64_VICE_Front-End>).

Down one more level, [this explains how wires work](<http://electriciantraining.tpub.com/14182/>), [Richard A. Steenbergen explains fiber](<https://www.nanog.org/meetings/nanog57/presentations/Monday/mon.tutorial.Steenbergen.Optical.39.pdf>), and [Pierret](<http://www.amazon.com/gp/product/0201543931/ref=as_li_qf_sp_asin_il_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0201543931&linkCode=as2&tag=abroaview-20&linkId=MXV5K7IJXWXJD446>) [explains](<http://www.amazon.com/gp/product/013061792X/ref=as_li_qf_sp_asin_il_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=013061792X&linkCode=as2&tag=abroaview-20&linkId=N7YLCANVDPI3M35R>) transistors.

P.S. As an interview question, this is pretty much the antithesis of the [tptacek strategy](<http://sockpuppet.org/blog/2015/03/06/the-hiring-post/>). From what I've seen, my guess is that tptacek-style interviews are much better filters than open ended questions like this.

Thanks to Marek Majkowski, Allison Kaptur, Mindy Preston, Julia Evans, Marie Clemessy, and Gordon P. Hemsley for providing answers and links to resources with answers! Also, thanks to Julia Evans and Sumana Harihareswara for convincing me to turn these questions into a blog post.

* * *

  1. I mostly don't have questions about stuff that happens inside a PC listed, but I'm pretty curious about how modern high-speed busses work and how high-speed chips deal with the massive inductance they must have to deal with getting signals to and from the chip. [return]


[← Given that we spend little on testing, how should we test software?](<https://danluu.com/testing/>) [Goodhearting IQ, cholesterol, and tail latency →](<https://danluu.com/percentile-latency/>)
