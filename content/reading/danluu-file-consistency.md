+++
title = "Files are hard"
date  = 2015-12-01
[taxonomies]
tags  = ["danluu"]
+++

I haven't used a desktop email client in years. None of them could handle the volume of email I get without at least occasionally corrupting my mailbox. Pine, Eudora, and outlook have all corrupted my inbox, forcing me to restore from backup. How is it that desktop mail clients are less reliable than gmail, even though my gmail account not only handles more email than I ever had on desktop clients, but also allows simultaneous access from multiple locations across the globe? Distributed systems have an unfair advantage, in that they can be robust against total disk failure in a way that desktop clients can't, but none of the file corruption issues I've had have been from total disk failure. Why has my experience with desktop applications been so bad?

Well, what sort of failures can occur? Crash consistency (maintaining consistent state even if there's a crash) is probably the easiest property to consider, since we can assume that everything, from the filesystem to the disk, works correctly; let's consider that first.

### Crash Consistency

Pillai et al. had a [paper](<https://www.usenix.org/system/files/conference/osdi14/osdi14-paper-pillai.pdf>) and [presentation](<https://www.usenix.org/sites/default/files/conference/protected-files/osdi14_slides_pillai.pdf>) at OSDI '14 on exactly how hard it is to save data without corruption or data loss.

Let's look at a simple example of what it takes to save data in a way that's robust against a crash. Say we have a file that contains the text `a foo` and we want to update the file to contain `a bar`. The pwrite function looks like it's designed for this exact thing. It takes a file descriptor, what we want to write, a length, and an offset. So we might try
    
    
    pwrite([file], “bar”, 3, 2)  // write 3 bytes at offset 2
    

What happens? If nothing goes wrong, the file will contain `a bar`, but if there's a crash during the write, we could get `a boo`, `a far`, or any other combination. Note that you may want to consider this an example over sectors or blocks and not chars/bytes.

If we want atomicity (so we either end up with `a foo` or `a bar` but nothing in between) one standard technique is to make a copy of the data we're about to change in an [undo log](<http://www.cburch.com/cs/340/reading/log/index.html>) file, modify the “real” file, and then delete the log file. If a crash happens, we can recover from the log. We might write something like
    
    
    creat(/dir/log);
    write(/dir/log, “2,3,foo”, 7);
    pwrite(/dir/orig, “bar”, 3, 2);
    unlink(/dir/log);
    

This should allow recovery from a crash without data corruption via the undo log, at least if we're using `ext3` and we made sure to mount our drive with `data=journal`. But we're out of luck if, like most people, we're using the default1 \-- with the default `data=ordered`, the `write` and `pwrite` syscalls can be reordered, causing the write to `orig` to happen before the write to the log, which defeats the purpose of having a log. We can fix that.
    
    
    creat(/dir/log);
    write(/dir/log, “2, 3, foo”);
    fsync(/dir/log);  // don't allow write to be reordered past pwrite
    pwrite(/dir/orig, 2, “bar”);
    fsync(/dir/orig);
    unlink(/dir/log);
    

That should force things to occur in the correct order, at least if we're using ext3 with `data=journal` or `data=ordered`. If we're using `data=writeback`, a crash during the the `write` or `fsync` to log can leave `log` in a state where the filesize has been adjusted for the write of “bar”, but the data hasn't been written, which means that the log will contain random garbage. This is because with `data=writeback`, metadata is [journaled](<https://en.wikipedia.org/wiki/Journaling_file_system>), but data operations aren't, which means that data operations (like writing data to a file) aren't ordered with respect to metadata operations (like adjusting the size of a file for a write).

We can fix that by adding a checksum to the log file when creating it. If the contents of `log` don't contain a valid checksum, then we'll know that we ran into the situation described above.
    
    
    creat(/dir/log);
    write(/dir/log, “2, 3, [checksum], foo”);  // add checksum to log file
    fsync(/dir/log);
    pwrite(/dir/orig, 2, “bar”);
    fsync(/dir/orig);
    unlink(/dir/log);
    

That's safe, at least on current configurations of ext3. But it's legal for a filesystem to end up in a state where the log is never created unless we issue an fsync to the parent directory.
    
    
    creat(/dir/log);
    write(/dir/log, “2, 3, [checksum], foo”);
    fsync(/dir/log);
    fsync(/dir);  // fsync parent directory of log file
    pwrite(/dir/orig, 2, “bar”);
    fsync(/dir/orig);
    unlink(/dir/log);
    

That should prevent corruption on any Linux filesystem, but if we want to make sure that the file actually contains “bar”, we need another fsync at the end.
    
    
    creat(/dir/log);
    write(/dir/log, “2, 3, [checksum], foo”);
    fsync(/dir/log);
    fsync(/dir);
    pwrite(/dir/orig, 2, “bar”);
    fsync(/dir/orig);
    unlink(/dir/log);
    fsync(/dir);
    

That results in consistent behavior and guarantees that our operation actually modifies the file after it's completed, as long as we assume that `fsync` actually flushes to disk. OS X and some versions of ext3 have an fsync that doesn't really flush to disk. OS X requires `fcntl(F_FULLFSYNC)` to flush to disk, and some versions of ext3 only flush to disk if the the [inode](<https://en.wikipedia.org/wiki/Inode>) changed (which would only happen at most once a second on writes to the same file, since the inode mtime has one second granularity), as an optimization.

Even if we assume fsync issues a flush command to the disk, some disks ignore flush directives for the same reason fsync is gimped on OS X and some versions of ext3 -- to look better in benchmarks. Handling that is beyond the scope of this post, but the [Rajimwale et al. DSN '11 paper](<http://www.researchgate.net/profile/Vijay_Chidambaram/publication/220958003_Coerced_Cache_Eviction_and_discreet_mode_journaling_Dealing_with_misbehaving_disks/links/54d0f0190cf29ca811040c8a.pdf>) and related work cover that issue.

### Filesystem semantics

When the authors examined ext2, ext3, ext4, btrfs, and xfs, they found that there are substantial differences in how code has to be written to preserve consistency. They wrote a tool that collects block-level filesystem traces, and used that to determine which properties don't hold for specific filesystems. The authors are careful to note that they can only determine when properties don't hold -- if they don't find a violation of a property, that's not a guarantee that the property holds.

![Different filesystems have very different properties](https://danluu.com/images/file-consistency/fs_properties.png)

Xs indicate that a property is violated. The atomicity properties are basically what you'd expect, e.g., no X for single sector overwrite means that writing a single sector is atomic. The authors note that the atomicity of single sector overwrite sometimes comes from a property of the disks they're using, and that running these filesystems on some disks won't give you single sector atomicity. The ordering properties are also pretty much what you'd expect from their names, e.g., an X in the “Overwrite -> Any op” row means that an overwrite can be reordered with some operation.

After they created a tool to test filesystem properties, they then created a tool to check if any applications rely on any potentially incorrect filesystem properties. Because invariants are application specific, the authors wrote checkers for each application tested.

![Everything is broken](https://danluu.com/images/file-consistency/program_bugs.png)

The authors find issues with most of the applications tested, including things you'd really hope would work, like LevelDB, HDFS, Zookeeper, and git. In a talk, one of the authors noted that the developers of sqlite have a very deep understanding of these issues, but even that wasn't enough to prevent all bugs. That speaker also noted that version control systems were particularly bad about this, and that the developers had a pretty lax attitude that made it very easy for the authors to find a lot of issues in their tools. The most common class of error was incorrectly assuming ordering between syscalls. The next most common class of error was assuming that syscalls were atomic2. These are fundamentally the same issues people run into when doing multithreaded programming. Correctly reasoning about re-ordering behavior and inserting barriers correctly is hard. But even though shared memory concurrency is considered a hard problem that requires great care, writing to files isn't treated the same way, even though it's actually harder in a number of ways.

Something to note here is that while btrfs's semantics aren't inherently less reliable than ext3/ext4, many more applications corrupt data on top of btrfs because developers aren't used to coding against filesystems that allow directory operations to be reordered (ext2 is perhaps the most recent widely used filesystem that allowed that reordering). We'll probably see a similar level of bug exposure when people start using NVRAM drives that have byte-level atomicity. People almost always just run some tests to see if things work, rather than making sure they're coding against what's legal in a POSIX filesystem.

Hardware memory ordering semantics are usually [well documented](<https://danluu.com/new-cpu-features/#memory-concurrency>) in a way that makes it simple to determine precisely which operations can be reordered with which other operations, and which operations are atomic. By contrast, here's [the ext manpage](<http://man7.org/linux/man-pages/man5/ext4.5.html>) on its three data modes:

> journal: All data is committed into the journal prior to being written into the main filesystem.
> 
> ordered: This is the default mode. All data is forced directly out to the main file system prior to its metadata being committed to the journal.
> 
> writeback: Data ordering is not preserved – data may be written into the main filesystem after its metadata has been committed to the journal. **This is rumoured to be** the highest-throughput option. It guarantees internal filesystem integrity, however it can allow old data to appear in files after a crash and journal recovery.

The manpage literally refers to rumor. This is the level of documentation we have. If we look back at our example where we had to add an `fsync` between the `write(/dir/log, “2, 3, foo”)` and `pwrite(/dir/orig, 2, “bar”)` to prevent reordering, I don't think the necessity of the `fsync` is obvious from the description in the manpage. If you look at the hardware memory ordering “manpage” above, it specifically defines the ordering semantics, and it certainly doesn't rely on rumor.

This isn't to say that filesystem semantics aren't documented anywhere. Between [lwn](<http://lwn.net/>) and LKML, it's possible to get a good picture of how things work. But digging through all of that is hard enough that it's still quite common [for there to be long, uncertain discussions on how things work](<http://austingroupbugs.net/view.php?id=672>). A lot of the information out there is wrong, and even when information was right at the time it was posted, it often goes out of date.

When digging through archives, I've often seen a post from 2005 cited to back up the claim that OS X `fsync` is the same as Linux `fsync`, and that OS X `fcntl(F_FULLFSYNC)` is even safer than anything available on Linux. Even at the time, I don't think that was true for the 2.4 kernel, although it was true for the 2.6 kernel. But since 2008 or so Linux 2.6 with ext3 will do a full flush to disk for each fsync (if the disk supports it, and the filesystem hasn't been specially configured with barriers off).

Another issue is that you often also see exchanges [like this one](<http://lkml.iu.edu/hypermail/linux/kernel/0908.3/01481.html>):

**Dev 1** : Personally, I care about metadata consistency, and ext3 documentation suggests that journal protects its integrity. Except that it does not on broken storage devices, and you still need to run fsck there.  
**Dev 2** : as the ext3 authors have stated many times over the years, you still need to run fsck periodically anyway.  
**Dev 1** : Where is that documented?  
**Dev 2** : linux-kernel mailing list archives.  
**Dev 3** : Probably from some 6-8 years ago, in e-mail postings that I made.  


Where's this documented? Oh, in some mailing list post 6-8 years ago (which makes it 12-14 years from today). I don't mean to pick on filesystem devs. The fs devs whose posts I've read are quite polite compared to LKML's reputation; they generously spend a lot of their time responding to basic questions and I'm impressed by how patient the expert fs devs are with askers, but it's hard for outsiders to troll through a decade and a half of mailing list postings to figure out which ones are still valid and which ones have been obsoleted!

In their OSDI 2014 talk, the authors of the paper we're discussing noted that when they reported bugs they'd found, developers would often respond “POSIX doesn't let filesystems do that”, without being able to point to any specific POSIX documentation to support their statement. If you've followed Kyle Kingsbury's Jepsen work, this may sound familiar, except devs respond with “filesystems don't do that” instead of “networks don't do that”. I think this is understandable, given how much misinformation is out there. Not being a filesystem dev myself, I'd be a bit surprised if I don't have at least one bug in this post.

### Filesystem correctness

We've already encountered a lot of complexity in saving data correctly, and this only scratches the surface of what's involved. So far, we've assumed that the disk works properly, or at least that the filesystem is able to detect when the disk has an error via [SMART](<https://en.wikipedia.org/wiki/S.M.A.R.T.>) or some other kind of monitoring. I'd always figured that was the case until I started looking into it, but that assumption turns out to be completely wrong.

The [Prabhakaran et al. SOSP 05 paper](<http://research.cs.wisc.edu/wind/Publications/iron-sosp05.pdf>) examined how filesystems respond to disk errors in some detail. They created a fault injection layer that allowed them to inject disk faults and then ran things like `chdir`, `chroot`, `stat`, `open`, `write`, etc. to see what would happen.

Between ext3, reiserfs, and NTFS, reiserfs is the best at handling errors and it seems to be the only filesystem where errors were treated as first class citizens during design. It's mostly consistent about propagating errors to the user on reads, and calling `panic` on write failures, which triggers a restart and recovery. This general policy allows the filesystem to gracefully handle read failure and avoid data corruption on write failures. However, the authors found a number of inconsistencies and bugs. For example, reiserfs doesn't correctly handle read errors on indirect blocks and leaks space, and a specific type of write failure doesn't prevent reiserfs from updating the journal and committing the transaction, which can result in data corruption.

Reiserfs is the good case. The authors found that ext3 ignored write failures in most cases, and rendered the filesystem read-only in most cases for read failures. This seems like pretty much the opposite of the policy you'd want. Ignoring write failures can easily result in data corruption, and remounting the filesystem as read-only is a drastic overreaction if the read error was a transient error (transient errors are common). Additionally, ext3 did the least consistency checking of the three filesystems and was the most likely to not detect an error. In one presentation, one of the authors remarked that the ext3 code had lots of comments like “I really hope a write error doesn't happen here" in places where errors weren't handled.

NTFS is somewhere in between. The authors found that it has many consistency checks built in, and is pretty good about propagating errors to the user. However, like ext3, it ignores write failures.

The paper has much more detail on the exact failure modes, but the details are mostly of historical interest as many of the bugs have been fixed.

It would be really great to see an updated version of the paper, and in one presentation someone in the audience asked if there was more up to date information. The presenter replied that they'd be interested in knowing what things look like now, but that it's hard to do that kind of work in academia because grad students don't want to repeat work that's been done before, which is pretty reasonable given the incentives they face. Doing replications is a lot of work, often nearly as much work as the original paper, and replications usually give little to no academic credit. This is one of the many cases where the incentives align very poorly with producing real world impact.

The [Gunawi et al. FAST 08](<http://usenix.org/legacy/event/fast08/tech/full_papers/gunawi/gunawi_html/index.html>) is another paper it would be great to see replicated today. That paper follows up the paper we just looked at, and examines the error handling code in different file systems, using a simple static analysis tool to find cases where errors are being thrown away. Being thrown away is defined very loosely in the paper --- code like the following
    
    
    if (error) {
        printk(“I have no idea how to handle this error\n”);
    }
    

is considered _not_ throwing away the error. Errors are considered to be ignored if the execution flow of the program doesn't depend on the error code returned from a function that returns an error code.

With that tool, they find that most filesystems drop a lot of error codes:

  
  
  
---  
  
**By % Broken** |  **By Viol/Kloc** |   
  
Rank 

FS  |  Frac.  |  FS Viol/Kloc |   
  
1 

IBM JFS  |  24.4  |  ext3  |  7.2  |   
  
2 

ext3  |  22.1  |  IBM JFS  |  5.6  |   
  
3 

JFFS v2  |  15.7  |  NFS Client  |  3.6  |   
  
4 

NFS Client  |  12.9  |  VFS  |  2.9  |   
  
5 

CIFS  |  12.7  |  JFFS v2  |  2.2  |   
  
6 

MemMgmt  |  11.4  |  CIFS  |  2.1  |   
  
7 

ReiserFS  |  10.5  |  MemMgmt  |  2.0  |   
  
8 

VFS  |  8.4  |  ReiserFS  |  1.8  |   
  
9 

NTFS  |  8.1  |  XFS  |  1.4  |   
  
10 

XFS  |  6.9  |  NFS Server  |  1.2    
Comments they found next to ignored errors include: "Should we pass any errors back?", "Error, skip block and hope for the best.", "There's no way of reporting error returned from ext3_mark_inode_dirty() to user space. So ignore it.", "Note: todo: log error handler.", "We can't do anything about an error here.", "Just ignore errors at this point. There is nothing we can do except to try to keep going.", "Retval ignored?", and "Todo: handle failure." One thing to note is that in a lot of cases, ignoring an error is more of a symptom of an architectural issue than a bug per se (e.g., ext3 ignored write errors during checkpointing because it didn't have any kind of recovery mechanism). But even so, the authors of the papers found many real bugs.

### Error recovery

Every widely used filesystem has bugs that will cause problems on error conditions, which brings up two questions. Can recovery tools robustly fix errors, and how often do errors occur? How do they handle recovery from those problems? The [Gunawi et al. OSDI 08 paper](<http://usenix.org/legacy/events/osdi08/tech/full_papers/gunawi/gunawi_html/index.html>) looks at that and finds that fsck, a standard utility for checking and repairing file systems, “checks and repairs certain pointers in an incorrect order . . . the file system can even be unmountable after”. At this point, we know that it's quite hard to write files in a way that ensures their robustness even when the underlying filesystem is correct, the underlying filesystem will have bugs, and that attempting to repair corruption to the filesystem may damage it further or destroy it. How often do errors happen?

### Error frequency

The [Bairavasundaram et al. SIGMETRICS '07 paper](<http://bnrg.eecs.berkeley.edu/~randy/Courses/CS294.F07/11.1.pdf>) found that, depending on the exact model, between 5% and 20% of disks would have at least one error over a two year period. Interestingly, many of these were isolated errors -- 38% of disks with errors had only a single error, and 80% had fewer than 50 errors. [A follow-up study](<https://www.usenix.org/legacy/events/fast08/tech/full_papers/bairavasundaram/bairavasundaram_html/main.html>) looked at corruption and found that silent data corruption that was only detected by checksumming happened on .5% of disks per year, with one extremely bad model showing corruption on 4% of disks in a year. It's also worth noting that they found very high locality in error rates between disks on some models of disk. For example, there was one model of disk that had a very high error rate in one specific sector, making many forms of RAID nearly useless for redundancy. That's another study it would be nice to see replicated. [Most studies on disk focus on the failure rate of the entire disk](<https://www.backblaze.com/blog/hard-drive-reliability-q3-2015/>), but if what you're worried about is data corruption, errors in non-failed disks are more worrying than disk failure, which is easy to detect and mitigate.

### Conclusion

Files are hard. [Butler Lampson has remarked](<https://danluu.com/butler-lampson-1999/#parallelism>) that when they came up with threads, locks, and condition variables at PARC, they thought that they were creating a programming model that anyone could use, but that there's now decades of evidence that they were wrong. We've accumulated a lot of evidence that humans are very bad at reasoning about these kinds of problems, which are very similar to the problems you have when writing correct code to interact with current filesystems. Lampson suggests that the best known general purpose solution is to package up all of your parallelism into as small a box as possible and then have a wizard write the code in the box. Translated to filesystems, that's equivalent to saying that as an application developer, writing to files safely is hard enough that it should be done via some kind of library and/or database, not by directly making syscalls. Sqlite is quite good in terms of reliability if you want a good default. However, some people find it to be too heavyweight if all they want is a file-based abstraction. What they really want is a sort of polyfill for the file abstraction that works on top of all filesystems without having to understand the differences between different configurations (and even different versions) of each filesystem. Since that doesn't exist yet, when no existing library is sufficient, you need to checksum your data since you will get silent errors and corruption. The only questions are whether or not you detect the errors and whether or not your record format only destroys a single record when corruption happens, or if it destroys the entire database. As far as I can tell, most desktop email client developers have chosen to go the route of destroying all of your email if corruption happens. These studies also hammer home the point that [conventional testing isn't sufficient](<https://danluu.com/everything-is-broken/>). There were multiple cases where the authors of a paper wrote a relatively simple tool and found a huge number of bugs. You don't need any deep computer science magic to write the tools. The error propagation checker from the paper that found a ton of bugs in filesystem error handling was 4k LOC. If you read the paper, you'll see that the authors observed that the tool had a very large number of shortcomings because of its simplicity, but despite those shortcomings, it was able to find a lot of real bugs. I wrote a vaguely similar tool at my last job to enforce some invariants, and it was literally two pages of code. It didn't even have a real parser (it just went line-by-line through files and did some regexp matching to detect the simple errors that it's possible to detect with just a state machine and regexes), but it found enough bugs that it paid for itself in development time the first time I ran it. Almost every software project I've seen has a lot of low hanging testing fruit. Really basic [random testing](<https://danluu.com/testing/>), [static analysis](<https://danluu.com/pl-troll/>), and [fault injection](<https://aphyr.com/tags/jepsen>) can pay for themselves in terms of dev time pretty much the first time you use them.

### Appendix

I've probably covered less than 20% of the material in the papers I've referred to here. Here's a bit of info about some other neat info you can find in those papers, and others. [Pillai et al., OSDI '14](<https://www.usenix.org/system/files/conference/osdi14/osdi14-paper-pillai.pdf>): this papers goes into much more detail about what's required for crash consistency than this post does. It also gives a fair amount of detail about how exactly applications fail, including diagrams of traces that indicate what false assumptions are embedded in each trace. [Chidambara et al., FAST '12](<http://static.usenix.org/legacy/events/fast12/tech/full_papers/Chidambaram.pdf>): the same filesystem primitives are responsible for both consistency and ordering. The authors propose alternative primitives that separate these concerns, allow better performance while maintaining safety. [Rajimwale et al. DSN '01](<https://www.researchgate.net/publication/220958003_Coerced_Cache_Eviction_and_Discreet_Mode_Journaling_Dealing_with_Misbehaving_Disks>): you probably shouldn't use disks that ignore flush directives, but in case you do, here's a protocol that forces those disks to flush using normal filesystem operations. As you might expect, the performance for this is quite bad. [Prabhakaran et al. SOSP '05](<http://research.cs.wisc.edu/wind/Publications/iron-sosp05.pdf>): This has a lot more detail on filesystem responses to error than was covered in this post. The authors also discuss JFS, an IBM filesystem for AIX. Although it was designed for high reliability systems, it isn't particularly more reliable than the alternatives. Related material is covered further in [DSN '08](<http://research.cs.wisc.edu/adsl/Publications/pointer-dsn08.pdf>), [StorageSS '06](<http://research.cs.wisc.edu/adsl/Publications/trust-storagess06.pdf>), [DSN '06](<http://research.cs.wisc.edu/adsl/Publications/vmdep-dsn06.pdf>), [FAST '08](<http://research.cs.wisc.edu/adsl/Publications/parity-fast08.pdf>), and [USENIX '09](<http://research.cs.wisc.edu/adsl/Publications/envyfs-usenix09.pdf>), among others. [Gunawi et al. FAST '08](<http://usenix.org/legacy/event/fast08/tech/full_papers/gunawi/gunawi_html/index.html>) : Again, much more detail than is covered in this post on when errors get dropped, and how they wrote their tools. They also have some call graphs that give you one rough measure of the complexity involved in a filesystem. The XFS call graph is particularly messy, and one of the authors noted in a presentation that an XFS developer said that XFS was fun to work on since they took advantage of every possible optimization opportunity regardless of how messy it made things. [Bairavasundaram et al. SIGMETRICS '07](<http://bnrg.eecs.berkeley.edu/~randy/Courses/CS294.F07/11.1.pdf>): There's a lot of information on disk error locality and disk error probability over time that isn't covered in this post. [A followup paper in FAST08 has more details](<http://research.cs.wisc.edu/adsl/Publications/corruption-fast08.pdf>). [Gunawi et al. OSDI '08](<http://usenix.org/legacy/events/osdi08/tech/full_papers/gunawi/gunawi_html/index.html>): This paper has a lot more detail about when fsck doesn't work. In a presentation, one of the authors mentioned that fsck is the only program that's ever insulted him. Apparently, if you have a corrupt pointer that points to a superblock, fsck destroys the superblock (possibly rendering the disk unmountable), tells you something like "you dummy, you must have run fsck on a mounted disk", and then gives up. In the paper, the authors reimplement basically all of fsck using a declarative model, and find that the declarative version is shorter, easier to understand, and much easier to extend, at the cost of being somewhat slower. Memory errors are beyond the scope of this post, but [memory corruption](<https://danluu.com/why-ecc/>) can cause disk corruption. This is especially annoying because memory corruption can cause you to take a checksum of bad data and write a bad checksum. It's also possible to corrupt in memory pointers, which often results in something very bad happening. See the [Zhang et al. FAST '10 paper](<http://research.cs.wisc.edu/adsl/Publications/zfs-corruption-fast10.pdf>) for more on how ZFS is affected by that. There's a meme going around that ZFS is safe against memory corruption because it checksums, but that paper found that critical things held in memory aren't checksummed, and that memory errors can cause data corruption in real scenarios. The sqlite devs are serious about both [documentation](<https://www.sqlite.org/howtocorrupt.html>) and [testing](<https://www.sqlite.org/testing.html>). If I wanted to write a reliable desktop application, I'd start by reading the sqlite docs and then talking to some of the core devs. If I wanted to write a reliable distributed application I'd start by getting a job at Google and then reading the design docs and [postmortems](<https://danluu.com/postmortem-lessons/>) for GFS, Colossus, Spanner, etc. J/k, but not really. We haven't looked at formal methods at all, but there have been a variety of attempts to formally verify properties of filesystems, such as [SibylFS](<https://sibylfs.github.io/>). This list isn't intended to be exhaustive. It's just a list of things I've read that I think are interesting. **Update** : many people have read this post and suggested that, in the first file example, you should use the much simpler protocol of copying the file to modified to a temp file, modifying the temp file, and then renaming the temp file to overwrite the original file. In fact, that's probably the most common comment I've gotten on this post. If you think this solves the problem, I'm going to ask you to pause for five seconds and consider the problems this might have. The main problems this has are:

  * rename isn't atomic on crash. POSIX says that rename is atomic, but this only applies to normal operation, not to crashes.
  * even if the techinque worked, the performance is very poor
  * how do you handle hardlinks?
  * metadata can be lost; this can sometimes be preserved, under some filesystems, with ioctls, but now you have filesystem specific code just for the non-crash case
  * etc.

The fact that so many people thought that this was a simple solution to the problem demonstrates that this problem is one that people are prone to underestimating, even they're explicitly warned that people tend to underestimate this problem! **[This post reproduces some of the results from these papers on modern filesystems as of 2017](<https://danluu.com/filesystem-errors/>).** **[This talk (transcript) contains a number of newer results and discusses hardware issues in more detail](<https://danluu.com/deconstruct-files/>).** Thanks to Leah Hanson, Katerina Barone-Adesi, Jamie Brandon, Kamal Marhubi, Joe Wilder, David Turner, Benjamin Gilbert, Tom Murphy, Chris Ball, Joe Doliner, Alexy Romanov, Mindy Preston, Paul McJones, Evan Jones, and Jason Petersen for comments/corrections/discussion. 

* * *

  1. Turns out [some commercially supported distros](<https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Storage_Administration_Guide/ch-ext3.html>) only support `data=ordered`. Oh, and when I said `data=ordered` was the default, that's only the case if pre-2.6.30. After 2.6.30, there's a config option, `CONFIG_EXT3_DEFAULTS_TO_ORDERED`. If that's not set, the default becomes `data=writeback`. [return]
  2. Cases where overwrite atomicity is required were documented as known issues, and all such cases assumed single-block atomicity and not multi-block atomicity. By contrast, multiple applications (LevelDB, Mercurial, and HSQLDB) had bad data corruption bugs that came from assuming appends are atomic. That seems to be an indirect result of a commonly used update protocol, where modifications are logged via appends, and then logged data is written via overwrites. Application developers are careful to check for and handle errors in the actual data, but the errors in the log file are often overlooked. There are a number of other classes of errors discussed, and I recommend reading the paper for the details if you work on an application that writes files. [return]

[← Big companies v. startups](<https://danluu.com/startup-tradeoffs/>) [Why use ECC? →](<https://danluu.com/why-ecc/>)
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
