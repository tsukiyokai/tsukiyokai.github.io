+++
title = "What's worked in Computer Science: 1999 v. 2015"
date  = 2015-11-01
[taxonomies]
tags  = ["danluu"]
+++

In 1999, Butler Lampson gave a talk about the [past and future of “computer systems research”](<http://research.microsoft.com/pubs/68591/computersystemsresearch.pdf>). Here are his opinions from 1999 on "what worked". | Yes | Maybe | No  
---|---|---  
Virtual memory | Parallelism | Capabilities  
Address spaces | RISC | Fancy type systems  
Packet nets | Garbage collection | Functional programming  
Objects / subtypes | Reuse | Formal methods  
RDB and SQL |  | Software engineering  
Transactions |  | RPC  
Bitmaps and GUIs |  | Distributed computing  
Web |  | Security  
Algorithms |  |   
  
  
Basically everything that was a Yes in 1999 is still important today. Looking at the Maybe category, we have:

### Parallelism

This is, unfortunately, still a Maybe. Between the [end of Dennard scaling](<https://en.wikipedia.org/wiki/Dennard_scaling>) and the continued demand for compute, chips now expose plenty of the parallelism to the programmer. Concurrency has gotten much easier to deal with, but really extracting anything close to the full performance available isn't much easier than it was in 1999.

In 2009, [Erik Meijer and Butler Lampson talked about this](<https://channel9.msdn.com/Shows/Going+Deep/E2E-Erik-Meijer-and-Butler-Lampson-Abstraction-Security-Embodiment>), and Lampson's comment was that when they came up with threading, locks, and conditional variables at PARC, they thought they were creating something that programmers could use to take advantage of parallelism, but that they now have decades of evidence that they were wrong. Lampson further remarks that to do parallel programming, what you need to do is put all your parallelism into a little box and then have a wizard go write the code in that box. Not much has changed since 2009.

Also, note that I'm using the same criteria to judge all of these. Whenever you say something doesn't work, someone will drop in say that, no wait, here's a PhD that demonstrates that someone has once done this thing, or here are nine programs that demonstrate that Idris is, in fact, widely used in large scale production systems. I take Lampson's view, which is that if the vast majority of programmers are literally incapable of using a certain class of technologies, that class of technologies has probably not succeeded.

On recent advancements in parallelism, Intel [recently added features that make it easier to take advantage of trivial parallelism by co-scheduling multiple applications on the same machine without interference](<https://danluu.com//danluu.com/intel-cat/>), but outside of a couple big companies, no one's really taking advantage of this yet. They also added hardware support for STM recently, but it's still not clear how much STM helps with usability when designing large scale systems.

### [RISC](<https://danluu.com//danluu.com/risc-definition/>)

If this was a Maybe in 1999 it's certainly a No now. In the 80s and 90s a lot of folks, probably the majority of folks, believed RISC was going to take over the world and x86 was doomed. In 1991, Apple, IBM, and Motorola got together to create PowerPC (PPC) chips that were going to demolish Intel in the consumer market. They opened the Somerset facility for chip design, and collected a lot of their best folks for what was going to be a world changing effort. At the upper end of the market, DEC's Alpha chips were getting twice the performance of Intel's, and their threat to the workstation market was serious enough that Microsoft ported Windows NT to the Alpha. DEC started a project to do dynamic translation from x86 to Alpha; at the time the project started, the projected performance of x86 basically running in emulation on Alpha was substantially better than native x86 on Intel chips.

In 1995, Intel released the Pentium Pro. At the time, it had better workstation integer performance than anything else out there, including much more expensive chips targeted at workstations, and its floating point performance was within a factor of 2 of high-end chips. That immediately destroyed the viability of the mainstream Apple/IBM/Moto PPC chips, and in 1998 IBM pulled out of the Somerset venture1 and everyone gave up on really trying to produce desktop class PPC chips. Apple continued to sell PPC chips for a while, but they had to cook up bogus benchmarks to make the chips look even remotely competitive. By the time DEC finished their dynamic translation efforts, x86 in translation was barely faster than native x86 in floating point code, and substantially slower in integer code. While that was a very impressive technical feat, it wasn't enough to convince people to switch from x86 to Alpha, which killed DEC's attempts to move into the low-end workstation and high-end PC market.

In 1999, high-end workstations were still mostly RISC machines, and supercomputers were a mix of custom chips, RISC chips, and x86 chips. Today, Intel dominates the workstation market with x86, and the supercomputer market has also moved towards x86. Other than POWER, RISC ISAs were mostly wiped out (like PA-RISC) or managed to survive by moving to the low-margin embedded market (like MIPS), which wasn't profitable enough for Intel to pursue with any vigor. You can see a kind of instruction set arbitrage that MIPS and ARM have been able to take advantage of because of this. Cavium and ARM will sell you a network card that offloads a lot of processing to the NIC, which have a bunch of cheap MIPS and ARM processors, respectively, on board. The low-end processors aren't inherently better at processing packets than Intel CPUS; they're just priced low enough that Intel won't compete on price because they don't want to cannibalize their higher margin chips with sales of lower margin chips. MIPS and ARM have no such concerns because MIPS flunked out of the high-end processor market and ARM has yet to get there. If the best thing you can say about RISC chips is that they manage to exist in areas where the profit margins are too low for Intel to care, that's not exactly great evidence of a RISC victory. That Intel ceded the low end of the market might seem ironic considering Intel's origins, but they've always been aggressive about moving upmarket (they did the same thing when they transitioned from DRAM to SRAM to flash, ceding the barely profitable DRAM market to their competitors).

If there's any threat to x86, it's ARM, and it's their business model that's a threat, not their ISA. And as for their ISA, ARM's biggest inroads into mobile and personal computing came with ARMv7 and earlier ISAs, which aren't really more RISC-like than x862. In the area in which they dominated, their "modern" RISC-y ISA, ARMv8, is hopeless and will continue to be hopeless for years, and they'll continue to dominate with their non-RISC ISAs.

In retrospect, the reason RISC chips looked so good in the 80s was that you could fit a complete high-performance RISC microprocessor onto a single chip, which wasn't true of x86 chips at the time. But as we got more transistors, this mattered less.

It's possible to nitpick RISC being a no by saying that modern processors translate x86 ops into RISC micro-ops internally, but if you listened to talk at the time, people thought that having an external RISC ISA would be so much lower overhead that RISC would win, which has clearly not happened. Moreover, modern chips also do micro-op fusion in order to fuse operations into decidedly un-RISC-y operations. A clean RISC ISA is a beautiful thing. I sometimes re-read Dick Sites's [explanation of the Alpha design](<http://www.hpl.hp.com/hpjournal/dtj/vol4num4/vol4num4art1.pdf>) just to admire it, but it turns out beauty isn't really critical for the commercial success of an ISA.

### Garbage collection

This is a huge Yes now. Every language that's become successful since 1999 has GC and is designed for all normal users to use it to manage all memory. In five years, Rust or D might make that last sentence untrue, but even if that happens, GC will still be in the yes category.

### Reuse

Yes, I think, although I'm not 100% sure what Lampson was referring to here. Lampson said that reuse was a maybe because it sometimes works (for UNIX filters, OS, DB, browser) but was also flaky (for OLE/COM). There are now widely used substitutes for OLE; service oriented architectures also seem to fit his definition of re-use.

Looking at the No category, we have:

### Capabilities

Yes. Widely used on mobile operating systems.

### Fancy type systems

It depends on what qualifies as a fancy type system, but if “fancy” means something at least as fancy as Scala or Haskell, this is a No. That's even true if you relax the standard to an ML-like type system. Boy, would I love to be able to do everyday programming in an ML (F# seems particularly nice to me), but we're pretty far from that.

In 1999 C, and C++ were mainstream, along with maybe Visual Basic and Pascal, with Java on the rise. And maybe Perl, but at the time most people thought of it as a scripting language, not something you'd use for "real" development. PHP, Python, Ruby, and JavaScript all existed, but were mostly used in small niches. Back then, Tcl was one of the most widely used scripting languages, and it wasn't exactly widely used. Now, PHP, Python, Ruby, and JavaScript are not only more mainstream than Tcl, but more mainstream than C and C++. C# is probably the only other language in the same league as those languages in terms of popularity, and Go looks like the only language that's growing fast enough to catch up in the foreseeable future. Since 1999, we have a bunch of dynamic languages, and a few languages with type systems that are specifically designed not to be fancy.

Maybe I'll get to use F# for non-hobby projects in another 16 years, but things don't look promising.

### Functional programming

I'd lean towards Maybe on this one, although this is arguably a No. Functional languages are still quite niche, but functional programming ideas are now mainstream, at least for the HN/reddit/twitter crowd.

You might say that I'm being too generous to functional programming here because I have a soft spot for immutability. That's fair. In 1982, [James Morris wrote](<http://research.microsoft.com/en-us/um/people/simonpj/Papers/other-authors/morris-real-programming.pdf>):

> Functional languages are unnatural to use; but so are knives and forks, diplomatic protocols, double-entry bookkeeping, and a host of other things modern civilization has found useful. Any discipline is unnatural, in that it takes a while to master, and can break down in extreme situations. That is no reason to reject a particular discipline. The important question is whether functional programming in unnatural the way Haiku is unnatural or the way Karate is unnatural.
> 
> Haiku is a rigid form poetry in which each poem must have precisely three lines and seventeen syllables. As with poetry, writing a purely functional program often gives one a feeling of great aesthetic pleasure. It is often very enlightening to read or write such a program. These are undoubted benefits, but real programmers are more results-oriented and are not interested in laboring over a program that already works.
> 
> They will not accept a language discipline unless it can be used to write programs to solve problems the first time -- just as Karate is occasionally used to deal with real problems as they present themselves. A person who has learned the discipline of Karate finds it directly applicable even in bar-room brawls where no one else knows Karate. Can the same be said of the functional programmer in today's computing environments? No.

Many people would make the same case today. I don't agree, but that's a matter of opinion, not a matter of fact.

### Formal methods

Maybe? Formal methods have had high impact in a few areas. Model checking is omnipresent in chip design. Microsoft's [driver verification tool](<http://research.microsoft.com/pubs/70038/tr-2004-08.pdf>) has probably had more impact than all formal chip design tools combined, clang now has a fair amount of static analysis built in, and so on and so forth. But, formal methods are still quite niche, and the vast majority of developers don't apply formal methods.

### Software engineering

No. In 1995, David Parnas had a talk at ICSE (the premier software engineering conference) about the fact that even the ICSE papers that won their “most influential paper award” (including two of Parnas's papers) had [very little impact on industry](<https://danluu.com//danluu.com/empirical-pl/>).

Basically all of Parnas's criticisms are still true today. One of his suggestions, that there should be distinct conferences for researchers and for practitioners has been taken up, but there's not much cross-pollination between academic conferences like ICSE and FSE and practitioner-focused conferences like StrangeLoop and PyCon.

### RPC

Yes. In fact RPCs are now so widely used that I've seen multiple RPCs considered harmful talks.

### Distributed systems

Yes. These are so ubiquitous that startups with zero distributed systems expertise regularly use distributed systems provided by Amazon or Microsoft, and it's totally fine. The systems aren't perfect and there are some infamous downtime incidents, but if you compare the bit error rate of random storage from 1999 to something like EBS or Azure Blob Storage, distributed systems don't look so bad.

### Security

Maybe? As with formal methods, a handful of projects with very high real world impact get a lot of mileage out of security research. But security still isn't a first class concern for most programmers.

### Conclusion

What's worked in computer systems research?

Topic | 1999 | 2015  
---|---|---  
Virtual memory | Yes | Yes  
Address spaces | Yes | Yes  
Packet nets | Yes | Yes  
Objects / subtypes | Yes | Yes  
RDB and SQL | Yes | Yes  
Transactions | Yes | Yes  
Bitmaps and GUIs | Yes | Yes  
Web | Yes | Yes  
Algorithms | Yes | Yes  
Parallelism | Maybe | Maybe  
RISC | Maybe | No  
Garbage collection | Maybe | Yes  
Reuse | Maybe | Yes  
Capabilities | No | Yes  
Fancy type systems | No | No  
Functional programming | No | Maybe  
Formal methods | No | Maybe  
Software engineering | No | No  
RPC | No | Yes  
Distributed computing | No | Yes  
Security | No | Maybe  
  
  
Not only is every Yes from 1999 still Yes today, seven of the Maybes and Nos were upgraded, and only one was downgraded. And on top of that, there are a lot of topics like neural networks that weren't even worth adding to the list as a No that are an unambiguous Yes today.

In 1999, I was taking the SATs and applying to colleges. Today, I'm not really all that far into my career, and the landscape has changed substantially; many previously impractical academic topics are now widely used in industry. I probably have twice again as much time until the end of my career and [things are changing faster now than they were in 1999](<https://danluu.com//danluu.com/infinite-disk/>). After reviewing Lampson's 1999 talk, I'm much more optimistic about research areas that haven't yielded much real-world impact (yet), like capability based computing and fancy type systems. It seems basically impossible to predict what areas will become valuable over the next thirty years.

### Correction

This post originally had Capabilities as a No in 2015. In retrospect, I think that was a mistake and it should have been a Yes due to use on mobile.

Thanks to Seth Holloway, Leah Hanson, Ian Whitlock, Lindsey Kuper, Chris Ball, Steven McCarthy, Joe Wilder, David Wragg, Sophia Wisdom, and Alex Clemmer for comments/discussion. 

* * *

  1. I know a fair number of folks who were relocated to Somerset from the east coast by IBM because they later ended up working at a company I worked at. It's interesting to me that software companies don't have the same kind of power over employees, and can't just insist that employees move to a new facility they're creating in some arbitrary location. [return]
  2. I once worked for a company that implemented both x86 and ARM decoders (I'm guessing it was the first company to do so for desktop class chips), and we found that our ARM decoder was physically larger and more complex than our x86 decoder. From talking to other people who've also implemented both ARM and x86 frontends, this doesn't seem to be unusual for high performance implementations. [return]


[← Why use ECC?](<https://danluu.com/why-ecc/>) [Infinite disk →](<https://danluu.com/infinite-disk/>)
  *[I said that Yahoo had been warped from the start by their fear of Microsoft]: Nam Nguyen points out this may have been incorrect — Yahoo's biggest fear was Google, not Microsoft — but insofar as this pair of quotes are relevant, they're being used because Graham wrote the most famous 'Microsoft is declining' posts, which is why these quotes are used. Whether or not Graham was right about Yahoo isn't material for this use case
  *[Microsoft has outperformed all of those companies since then]: as of my filling in the numbers when updating the draft of this post, in July 2024, if you include dividend reinvestment; I have drafts of this post going back to 2022 and Microsoft looked quite good every time I looked up the numbers
  *[$14B or $22B to $83B]: Most sources cite $22B to $78B, which probably stems from not understanding that the fiscal year and the calendar year are not the same. The revenue from the last four quarters Ballmer presided over was 20.403B+24.519B+18.529B+19.114B=82.565B
  *[current P/E ratio, would be 12th most valuable tech company in the world]: as of when the draft of this post was written in mid-2024
  *[like Paul Graham did when he judged Microsoft to be dead]: Graham notes that Microsoft is dead because it's no longer dangerous
  *[infallible]: in terms of maximizing the bottom line
  *[Writely]: Writely would later become Google Docs
  *[easy for the old guard at a company to shut down efforts to bring in senior outside expertise]: what usually happens is that the old guard ignore or slow play the new senior hires, saying they don't really understand the issues and you have to have been here a long time to get the company; this gets easier with each new hire since the old guard can point to the long list of failures as a reason to not listen to new outside hires
  *[never been seen before]: excluding the very early days, when you could say that there was only one programmer using one thing
  *[three guesses a turn]: fewer if you decide to have your team guess incorrectly
  *[JS for the Codenames bot failed to load!]: Aside to Dan: the JS is loaded from a seperate file due to Hugo a Hugo parsing issue with the old version of Hugo that's currently being used. Updating to a version where this is reasoanbly fixed would require 20+ fixes for this blog due to breaking changes Hugo has made over time. If you see this and Hugo is not in use anymore, you can probably inline the javascript here.
  *[The site had a bit of a smutty feel to it]: The front page has been cleaned up, but it makes sense to look at the site as it was when it was linked to, and the front page has also gotten considerably less Asian as the smut has cleaned up
  *[excel formatting]: There are bugs where people relatively frequently blame the user; maybe 5% to 10% of commenters like blaming the user on Excel formatting issues causing data corruption, but that's still much less than the half-ish we'll see on ML bias, and the level of agitation/irrigation/anger in the comments seems lower as well
  *[even particularly representative of text people send]: Looking at languages spoken vs. languages in the dictionary, for some reason, the dictionary has words from the #1, #2, #3, #4, #6, and #9 most spoken languages, but is missing #5, #7, and #8 for some reason, although there's a bit of overlap in one case
  *[Vietnamese]: of course, you can substitute any other minority here as well
  *[Maybe so for that particular person]: Although I doubt it — my experience is that people who say this sort of thing have a higher than average error rate
  *[they saw no need to ask me about it]: my HR rep asked me at once company, but of course that's one of the three companies they didn't get my name wrong
  *[It's just that now, many uses of ML make these kinds of biases a lot more legible to lay people and therefore likely to make the news]: and this increased visibility seems to have caused increased pushback in the form of people insisting that doing the opposite of what the user wants is not a bug
  *[don't care about this]: Until 2021 or so, workers in tech had an increasing amount of power and were sometimes able to push for more diversity, but the power seems to have shifted in the other direction for the foreseeable future
  *[Intel shifted effort away from verification and validation in order to increase velocity because their quality advantage wasn't doing them any favors]: One might hope that Intel's quality advantage was the reason it had monopoly power, but it looks like that was backwards and it was Intel's monopoly power that allowed it to invest in quality.
  *[absent a single dominant player, like Intel in its heyday]: Other possibilities, each unlikely, are that consumers will actually care about bias and meaningful regulatory change that doesn't backfire
  *[the memos from directors and other higher-ups]: that are available
  *[FTC leadership's]: at least among people whose memos were made public
  *[while it's growing rapidly]: BE staff acknowledge that mobile is rapidly growing, they do so in a minor way that certainly does not imply that mobile is or soon will be important
  *[it's generally very difficult to convert a lightly-engaged user who barely registers as an MAU to a heavily-engaged user who uses the product regularly]: There are some circumstances where this isn't true, but it would be difficult to make a compelling case that the search market in 2012 was one of those markets in general
  *[hyperscalers]: of course this term wasn't in use at the time
  *[most people in industry]: especially people familiar with the business or product side of the industry
  *[believe]: or believe something equivalent to
  *[onebox]: 'OneBoxes' were used to put vertical content above Google's SERP
  *[standard online service agreements]: standard agreements, as opposed to their bespoke negotiated agreements with large partners
  *[At an antitrust conference a while back]: Sorry, I didn't take notes on this and can't recall specifically who said this or even which conference, although I believe it was at the University of Chicago
  *[statements]: statements only, not explanations
  *[wouldn't be worth looking it up to copy]: perhaps one might copy it if one were bulk copying a large amount of code, but copying this single function to make haste is implausible
  *[SOM]: business school
  *[this is 50% per year for high-end connections]: Unfortunately, I don't know of a public source for low-end data, say 10%-ile or 1%-ile; let me know if you have numbers on this
  *[a fraction of median household income, that's substantially more than a current generation iPhone in the U.S. today.]: The estimates for Nigerian median income that I looked at seem good enough, but the Indian estimate I found was a bit iffier; if you have a good source for Indian income distribution, please pass it along.
  *[because]: For the 'real world' numbers, this is also because users with slow devices can't really use some of these sites, so their devices aren't counted in the distribution and PSI doesn't normalize for this.
  *[much of the web was unusable for people with slow connections and slow devices are no different]: One thing to keep in mind here is that having a slow device and a slow connection have multiplicative impacts.
  *[illustrative]: the founder has made similar comments elsewhere as well, so this isn't a one-off analogy for him, nor do I find it to be an unusual line of thinking in general
  *[74% to 85% of the performance of Apple]: I think it could be reasonable to cite a lower number, but I'm using the number he cited, not what I would cite
  *[74% to 85% of an all-time-great team is considered an embarrassment worthy of losing your job]: recall that, on a Tecno Spark 8, Discourse is 33 times slower than MyBB, which isn't particularly optimized for performance
  *[hardware engineers]: using this term loosely, to include materials scientists, etc., which is consistent with Knuth's comments
  *[long-term holdbacks]: where you keep a fraction of users on the old arm of the A/B test for a long duration, sometimes a year or more, in order to see the long-term impact of a change
  *[15 seconds looking up rough wealth numbers for these countries]: so, these probably aren't the optimal numbers one would use for a comparison, but I think they're good enough for this purpose
  *[an infinitely higher ratio]: To find the plausible range of underlying ratios, we can do a simple Bayesian adjustment here and we still find that the ratio of hate mail has increased by much more than the increase in traffic; maybe one can argue that hate mail for slow sites is spread across all slow sites, so a second adjustment needs to be done here?
  *[$30k/yr (which would result in a very good income in most countries where moderators are hired today, allowing them to have their pick of who to hire) on 1.6 million additional full-time staffers]: if you think this is too low, feel free to adjust this number up and the number of employees down
  *[normalized performance]: normalizing for both average performance as well as performance variance among competitors
  *[difficult to understand]: depending on what you mean by understand, it could be fair to say that it's impossible
  *[did support]: to be clear, this was first-line support where I talked to normal, non-technical, users, not a role like 'Field Applications Engineer', where the typical user you interact with is an engineer
  *[ensuring]: this word is used colloquially and not rigorously since you can't really guarantee this at scale
  *[protect the company]: for different values of protect the company than HR; to me, this feels more analogous to insurance, where there are people whose job it is to keep costs down. I've had insurance companies deny coverage on things that, by their written policy, should clearly be covered. In one case, I could call a company rep on the phone, who would explain to me why their company was wrong to deny the claim and how I should appeal, but written appeals were handed in writing and always denied. Luckily, when working for a big tech company, you can tell your employer what's happening, who will then tell the insurance company to stop messing with you, much like our big sporting event cloud support story, but for most users of insurance, this isn't an option and their only recourse is to sue, which they generally won't do or will settle for peanuts even if they do sue. Insurance companies know this and routinely deny claims without even looking at them (this has come out in discovery in lawsuits); accounting for the cost of lawsuits, this kind of claim denial is much cheaper than handling claims correctly. Similarly, providing actual support costs much more than not doing so and getting the user to stop pestering the company about how their account is broken saves money, hence standard responses claiming that the review is final, nothing can be done, etc.; anything to get the user to reduce the support cost of the company (except actually provide support)
  *[Jo Freeman]: among tech folks, probably best known as the author of The Tyranny of Structurelessness
  *[Kyle Vogt]: CEO, CTO, President, and co-founder
  *[Aaron McLear]: Communications VP
  *[Matt Wood]: Director of Systems Integrity
  *[Wood]: Director of Systems Integrity
  *[Vogt]: CEO, CTO, President, and co-founder
  *[McLear]: Communications VP
  *[Raman]: VP of Global Government Affairs Prashanthi
  *[Gil West]: COO
  *[Jeff Bleich]: Chief Legal Officer
  *[West]: COO
  *[David Estrada]: SVP of Government Affairs
  *[Estrada]: SVP of Government Affairs
  *[Prashanthi Raman]: VP of Global Government Affairs Prashanthi
  *[Eric Danko]: Senior Director of Federal Affairs
  *[Bleich]: Chief Legal Officer
  *[Alicia Fenrick]: Deputy General Counsel
  *[Matthew Wood]: Director of Systems Integrity
  *[Andrew Rubenstein]: Managing Legal Counsel
  *[Fenrick]: Deputy General Counsel
  *[Rubenstein]: Managing Legal Counsel
  *[Kyle]: CEO, CTO, President, and co-founder
  *[Danko]: Senior Director of Federal Affairs
  *[Jeff's argument here appears to be that, if he were there at the time, he would've seen the exact same opportunities that early Google enigneers did, and since Google did this, it must've been the right thing even if it doesn't look like it. But, a number of things that make it look like not the right thing actually made it not the right thing.]: When someone looks in the answer key and says, 'I would've come up with that', that's often plausible when their answer is perfect. But when they say that after seeing a specific imperfect answer, it's a bit less plausible that they'd reproduce the exact same mistakes
