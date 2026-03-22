+++
title = "Filesystem error handling"
date  = 2017-10-01
[taxonomies]
tags  = ["danluu"]
+++

We’re going to reproduce some [results from papers on filesystem robustness that were written up roughly a decade ago](<https://danluu.com/file-consistency/>): [Prabhakaran et al. SOSP 05 paper](<http://research.cs.wisc.edu/wind/Publications/iron-sosp05.pdf>), which injected errors below the filesystem and [Gunawi et al. FAST 08](<https://www.usenix.org/legacy/event/fast08/tech/full_papers/gunawi/gunawi_html/index.html>), which looked at how often filesystems failed to check return codes of functions that can return errors.

[Prabhakaran et al.](<http://research.cs.wisc.edu/wind/Publications/iron-sosp05.pdf>) injected errors at the block device level (just underneath the filesystem) and found that `ext3`, `resierfs`, `ntfs`, and `jfs` mostly handled read errors reasonbly but `ext3`, `ntfs`, and `jfs` mostly ignored write errors. While the paper is interesting, someone installing Linux on a system today is much more likely to use `ext4` than any of the now-dated filesystems tested by Prahbhakaran et al. We’ll try to reproduce some of the basic results from the paper on more modern filesystems like `ext4` and `btrfs`, some legacy filesystems like `exfat`, `ext3`, and `jfs`, as well as on `overlayfs`.

[Gunawi et al. ](<https://www.usenix.org/legacy/event/fast08/tech/full_papers/gunawi/gunawi_html/index.html>) found that errors weren’t checked most of the time. After we look at error injection on modern filesystems, we’ll look at how much (or little) filesystems have improved their error handling code.

### Error injection

A cartoon view of a file read might be: `pread syscall -> OS generic filesystem code -> filesystem specific code -> block device code -> device driver -> device controller -> disk`. Once the disk gets the request, it sends the data back up: `disk -> device controller -> device driver -> block device code -> filesystem specific code -> OS generic filesystem code -> pread`. We’re going to look at error injection at the block device level, right below the file system.

Let’s look at what happened when we injected errors in 2017 vs. what Prabhakaran et al. found in 2005.

| 2005| 2017  
---|---|---  
read| write| silent| read| write| silent| read| write| silent  
file| mmap  
btrfs| | prop| prop| prop| prop| prop| prop  
exfat| | prop| prop| ignore| prop| prop| ignore  
ext3| prop| ignore| ignore| prop| prop| ignore| prop| prop| ignore  
ext4| | prop| prop| ignore| prop| prop| ignore  
fat| | prop| prop| ignore| prop| prop| ignore  
jfs| prop| ignore| ignore| prop| ignore| ignore| prop| prop| ignore  
reiserfs| prop| prop| ignore|   
xfs| | prop| prop| ignore| prop| prop| ignore  
  
Each row shows results for one filesystem. `read` and `write` indicating reading and writing data, respectively, where the block device returns an error indicating that the operation failed. `silent` indicates a read failure (incorrect data) where the block device didn’t indicate an error. This could happen if there’s disk corruption, a transient read failure, or a transient write failure silently caused bad data to be written. `file` indicates that the operation was done on a file opened with `open` and `mmap` indicates that the test was done on a file mapped with `mmap`. `ignore` (red) indicates that the error was ignored, `prop` (yellow) indicates that the error was propagated and that the `pread` or `pwrite` syscall returned an error code, and `fix` (green) indicates that the error was corrected. No errors were corrected. Grey entries indicate configurations that weren’t tested.

From the table, we can see that, in 2005, `ext3` and `jfs` ignored write errors even when the block device indicated that the write failed and that things have improved, and that any filesystem you’re likely to use will correctly tell you that a write failed. `jfs` hasn’t improved, but `jfs` is now rarely used outside of legacy installations.

No tested filesystem other than `btrfs` handled silent failures correctly. The other filesystems tested neither duplicate nor checksum data, making it impossible for them to detect silent failures. `zfs` would probably also handle silent failures correctly but wasn’t tested. `apfs`, despite post-dating `btrfs` and `zfs`, made the explicit decision to not checksum data and silently fail on silent block device errors. We’ll discuss this more later.

In all cases tested where errors were propagated, file reads and writes returned `EIO` from `pread` or `pwrite`, respectively; `mmap` reads and writes caused the process to receive a `SIGBUS` signal.

The 2017 tests above used an 8k file where the first block that contained file data either returned an error at the block device level or was corrupted, depending on the test. The table below tests the same thing, but with a 445 byte file instead of an 8k file. The choice of 445 was arbitrary.

| 2005| 2017  
---|---|---  
read| write| silent| read| write| silent| read| write| silent  
file| mmap  
btrfs| | fix| fix| fix| fix| fix| fix  
exfat| | prop| prop| ignore| prop| prop| ignore  
ext3| prop| ignore| ignore| prop| prop| ignore| prop| prop| ignore  
ext4| | prop| prop| ignore| prop| prop| ignore  
fat| | prop| prop| ignore| prop| prop| ignore  
jfs| prop| ignore| ignore| prop| ignore| ignore| prop| prop| ignore  
reiserfs| prop| prop| ignore|   
xfs| | prop| prop| ignore| prop| prop| ignore  
  
In the small file test table, all the results are the same, except for `btrfs`, which returns correct data in every case tested. What’s happening here is that the filesystem was created on a rotational disk and, by default, `btrfs` duplicates filesystem metadata on rotational disks (it can be configured to do so on SSDs, but that’s not the default). Since the file was tiny, `btrfs` packed the file into the metadata and the file was duplicated along with the metadata, allowing the filesystem to fix the error when one block either returned bad data or reported a failure.

#### Overlay

[Overlayfs](<https://en.wikipedia.org/wiki/OverlayFS>) allows one file system to be “overlaid” on another. [As explained in the initial commit](<https://github.com/torvalds/linux/commit/e9be9d5e76e34872f0c37d72e25bc27fe9e2c54c>), one use case might be to put an (upper) read-write directory tree on top of a (lower) read-only directory tree, where all modifications go to the upper, writable layer.

Although not listed on the tables, we also tested every filesystem other than `fat` as the lower filesystem with overlay fs (ext4 was the upper filesystem for all tests). Every filessytem tested showed the same results when used as the bottom layer in `overlay` as when used alone. `fat` wasn’t tested because mounting `fat` resulted in a `filesystem not supported` error.

#### Error correction

`btrfs` doesn’t, by default, duplicate metadata on SSDs because the developers believe that redundancy wouldn’t provide protection against errors on SSD (which is the same reason `apfs` doesn’t have redundancy). SSDs do a kind of write coalescing, which is likely to cause writes which happen consecutively to fall into the same block. If that block has a total failure, the redundant copies would all be lost, so redundancy doesn’t provide as much protection against failure as it would on a rotational drive.

I’m not sure that this means that redundancy wouldn’t help -- Individual flash cells degrade with operation and lose charge as they age. SSDs have built-in [wear-leveling](<https://en.wikipedia.org/wiki/Wear_leveling>) and [error-correction](<https://en.wikipedia.org/wiki/Low-density_parity-check_code>) that’s designed to reduce the probability that a block returns bad data, but over time, some blocks will develop so many errors that the error-correction won’t be able to fix the error and the block will return bad data. In that case, a read should return some bad bits along with mostly good bits. AFAICT, the publicly available data on SSD error rates seems to line up with this view.

#### Error detection

Relatedly, it appears that [`apfs` doesn’t checksum data because “[apfs] engineers contend that Apple devices basically don’t return bogus data”](<http://dtrace.org/blogs/ahl/2016/06/19/apfs-part5/>). Publicly available studies on SSD reliability have not found that there’s a model that doesn’t sometimes return bad data. It’s a common conception that SSDs are less likely to return bad data than rotational disks, but when Google studied this across their drives, they found:

> The annual replacement rates of hard disk drives have previously been reported to be 2-9% [19,20], which is high compared to the 4-10% of flash drives we see being replaced in a 4 year period. However, flash drives are less attractive when it comes to their error rates. More than 20% of flash drives develop uncorrectable errors in a four year period, 30-80% develop bad blocks and 2-7% of them develop bad chips. In comparison, previous work [1] on HDDs reports that only 3.5% of disks in a large population developed bad sectors in a 32 months period – a low number when taking into account that the number of sectors on a hard disk is orders of magnitudes larger than the number of either blocks or chips on a solid state drive, and that sectors are smaller than blocks, so a failure is less severe.

While there is one sense in which SSDs are more reliable than rotational disks, there’s also a sense in which they appear to be less reliable. It’s not impossible that Apple uses some kind of custom firmware on its drive that devotes more bits to error correction than you can get in publicly available disks, but even if that’s the case, you might plug a non-apple drive into your apple computer and want some kind of protection against data corruption.

### Internal error handling

Now that we’ve reproduced some tests from Prabhakaran et al., we’re going to move on to [Gunawi et al.](<https://www.usenix.org/legacy/event/fast08/tech/full_papers/gunawi/gunawi_html/index.html>). Since the paper is fairly involved, we’re just going to look at one small part of the paper, the part where they examined three function calls, `filemap_fdatawait`, `filemap_fdatawrite`, and `sync_blockdev` to see how often errors weren’t checked for these functions.

Their justification for looking at these function is given as:

> As discussed in Section 3.1, a function could return more than one error code at the same time, and checking only one of them suffices. However, if we know that a certain function only returns a single error code and yet the caller does not save the return value properly, then we would know that such call is really a flaw. To find real flaws in the file system code, we examined three important functions that we know only return single error codes: sync_blockdev, filemap_fdatawrite, and filemap_fdatawait. A file system that does not check the returned error codes from these functions would obviously let failures go unnoticed in the upper layers.

Ignoring errors from these functions appears to have fairly serious consequences. The documentation for `filemap_fdatawait` says:

> filemap_fdatawait — wait for all under-writeback pages to complete ... Walk the list of under-writeback pages of the given address space and wait for all of them. Check error status of the address space and return it. Since the error status of the address space is cleared by this function, callers are responsible for checking the return value and handling and/or reporting the error.

The comment next to the code for `sync_blockdev` reads:

> Write out and wait upon all the dirty data associated with a block device via its mapping. Does not take the superblock lock.

In both of these cases, it appears that ignoring the error code could mean that data would fail to get written to disk without notifying the writer that the data wasn’t actually written?

Let’s look at how often calls to these functions didn’t completely ignore the error code:

fn | 2008 | '08 % | 2017 | '17 %  
---|---|---|---|---  
filemap_fdatawait | 7 / 29 | 24 | 12 / 17 | 71  
filemap_fdatawrite | 17 / 47 | 36 | 13 / 22 | 59  
sync_blockdev | 6 / 21 | 29 | 7 / 23 | 30  
  
This table is for all code in linux under `fs`. Each row shows data for calls of one function. For each year, the leftmost cell shows the number of calls that do something with the return value over the total number of calls. The cell to the right shows the percentage of calls that do something with the return value. “Do something” is used very loosely here -- branching on the return value and then failing to handle the error in either branch, returning the return value and having the caller fail to handle the return value, as well as saving the return value and then ignoring it are all considered doing something for the purposes of this table.

For example Gunawi et al. noted that `cifs/transport.c` had
    
    
    int SendReceive () { 
        int rc;
        rc = cifs_sign_smb(); // 
        ... 
        rc = smb_send();
    }
    

Although `cifs_sign_smb` returned an error code, it was never checked before being overwritten by `smb_send`, which counted as being used for our purposes even though the error wasn’t handled.

Overall, the table appears to show that many more errors are handled now than were handled in 2008 when Gunawi et al. did their analysis, but it’s hard to say what this means from looking at the raw numbers because it might be ok for some errors not to be handled and different lines of code are executed with different probabilities.

### Conclusion

Filesystem error handling seems to have improved. Reporting an error on a `pwrite` if the block device reports an error is perhaps the most basic error propagation a robust filesystem should do; few filesystems reported that error correctly in 2005. Today, most filesystems will correctly report an error when the simplest possible error condition that doesn’t involve the entire drive being dead occurs if there are no complicating factors.

Most filesystems don’t have checksums for data and leave error detection and correction up to userspace software. When I talk to server-side devs at big companies, their answer is usually something like “who cares? All of our file accesses go through a library that checksums things anyway and redundancy across machines and datacenters takes care of failures, so we only need error detection and not correction”. While that’s true for developers at certain big companies, there’s a lot of software out there that isn’t written robustly and just assumes that filesystems and disks don’t have errors.

_This was a joint project with Wesley Aptekar-Cassels; the vast majority of the work for the project was done while pair programming at[RC](<https://www.recurse.com/scout/click?t=b504af89e87b77920c9b60b2a1f6d5e8>). We also got _a lot _of help from Kate Murphy. Both Wesley (w.aptekar@gmail.com) and Kate (hello@kate.io) are looking for work. They’re great and I highly recommend talking to them if you’re hiring!_

### Appendix: error handling in C

A fair amount of effort has been applied to get error handling right. But C makes it very easy to get things wrong, even when you apply a fair amount effort and even apply extra tooling. One example of this in the code is the `submit_one_bio` function. If you look at the definition, you can see that it’s annotated with `__must_check`, which will cause a compiler warning when the result is ignored. But if you look at calls of `submit_one_bio`, you’ll see that its callers aren’t annotated and can ignore errors. If you dig around enough you’ll find one path of error propagation that looks like:
    
    
    submit_one_bio
    submit_extent_page
    __extent_writepage
    extent_write_full_page
    write_cache_pages
    generic_writepages
    do_writepages
    __filemap_fdatawrite_range
    __filemap_fdatawrite
    filemap_fdatawrite
    

Nine levels removed from `submit_one_bio`, we see our old friend, `filemap_fdatawrite, which we know often doesn’t get checked for errors.

There's a very old debate over how to prevent things like this from accidentally happening. One school of thought, which I'll call the Uncle Bob (UB) school believes that [we can't fix these kinds of issues with tools or processes and simply need to be better programmers in order to avoid bugs](<https://twitter.com/danluu/status/916315156199636992>). You'll often hear people of the UB school say things like, "you can't get rid of all bugs with better tools (or processes)". In his famous and well-regarded talk, [Simple Made Easy](<https://github.com/matthiasn/talk-transcripts/blob/master/Hickey_Rich/SimpleMadeEasy.md>), Rich Hickey says

> What's true of every bug found in the field?
> 
> [Audience reply: Someone wrote it?] [Audience reply: It got written.]
> 
> It got written. Yes. What's a more interesting fact about it? It passed the type checker.
> 
> [Audience laughter]
> 
> What else did it do?
> 
> [Audience reply: (Indiscernible)]
> 
> It passed all the tests. Okay. So now what do you do? Right? I think we're in this world I'd like to call guardrail programming. Right? It's really sad. We're like: I can make change because I have tests. Who does that? Who drives their car around banging against the guardrail saying, "Whoa! I'm glad I've got these guardrails because I'd never make it to the show on time."
> 
> [Audience laughter]

If you watch the talk, Rich uses "simplicity" the way Uncle Bob uses "discipline". They way these statements are used, they're roughly equivalent to Ken Thompson saying "[Bugs are bugs. You write code with bugs because you do](<https://twitter.com/danluu/status/885214004649615360>)". The UB school throws tools and processes under the bus, saying that it's unsafe to rely solely on tools or processes.

Rich's rhetorical trick is brilliant -- I've heard that line quoted tens of times since the talk to argue against tests or tools or types. But, like guardrails, most tools and processes aren't about eliminating all bugs, they're about reducing the severity or probability of bugs. If we look at this particular function call, we can see that a static analysis tool failed to find this bug. Does that mean that we should give up on static analysis tools? A static analysis tool could look for all calls of `submit_one_bio` and show you the cases where the error is propagated up N levels only to be dropped. Gunawi et al. did exactly that and found _a lot_ of bugs. A person basically can't do the same thing without tooling. They could try, but people are lucky if they get 95% accuracy when manually digging through things like this. The sheer volume of code guarantees that a human doing this by hand would make mistakes.

Even better than a static analysis tool would be a language that makes it harder to accidentally forget about checking for an error. One of the issues here is that it's sometimes valid to drop an error. There are a number of places where there's no interace that allows an error to get propagated out of the filesystem, making it correct to drop the error, modulo changing the interface. In the current situation, as an outsider reading the code, if you look at a bunch of calls that drop errors, it's very hard to say, for all of them, which of those is a bug and which of those is correct. If the default is that we have a kind of guardrail that says "this error must be checked", people can still incorrectly ignore errors, but you at least get an annotation that the omission was on purpose. For example, if you're forced to specifically write code that indicates that you're ignoring an error, and in code that's inteded to be robust, like filesystem code, code that drops an error on purpose is relatively likely to be accompanied by a comment explaining why the error was dropped.

### Appendix: why wasn't this done earlier?

After all, it would be nice if we knew if modern filesystems could do basic tasks correctly. Filesystem developers probably know this stuff, but since I don't [follow LKML](<http://lkml.iu.edu/hypermail/linux/kernel/0908.3/01481.html>), I had no idea whether or not things had improved since 2005 until we ran the experiment.

The papers we looked at here came out of Andrea and Remzi Arpaci-Dusseau's research lab. Remzi has a talk where he mentioned that grad students don't want to reproduce and update old work. That's entirely reasonable, given the incentives they face. And I don't mean to pick on academia here -- this work came out of academia, not industry. It's possible this kind of work simply wouldn't have happened if not for the academic incentive system.

In general, it seems to be quite difficult to fund work on correctness. There are a fair number of papers on new ways to find bugs, but that's relatively little work on applying existing techniques to existing code. In academia, that seems to be hard to get a good publication out of, in the open source world, that seems to be less interesting to people than writing new code. That's also entirely reasonable -- people should work on what they want, and even if they enjoy working on correctness, that's probably not a great career decision in general. I was at the [RC](<https://www.recurse.com/scout/click?t=b504af89e87b77920c9b60b2a1f6d5e8>) career fair the other night and my badge said I was interested in testing. The first person who chatted me up opened with "do you work in QA?". Back when I worked in hardware, that wouldn't have been a red flag, but in software, "QA" is code for a low-skill, tedious, and poorly paid job. Much of industry considers testing and QA to be an afterthought. As a result, open source projects that companies rely on are often [woefully underfunded](<https://en.wikipedia.org/wiki/OpenSSL>). Google funds some great work (like afl-fuzz), but that's the exception and not the rule, even within Google, and most companies don't fund any open source work. The work in this post was done by a few people who are intentionally temporarily unemployed, which isn't really a scalable model.

Occasionally, you'll see someone spend a lot of effort on immproving correctness, but that's usually done as a massive amount of free labor. Kyle Kingsbury might be the canonical example of this -- my understanding is that he worked on the [Jepsen distributed systems testing tool](<http://jepsen.io/>) on nights and weekends for years before turning that into a consulting business. It's great that he did that -- he showed that almost every open source distributed system had serious data loss or corruption bugs. I think that's great, but stories about heoric effort like that always worry me because heroism doesn't scale. If Kyle hadn't come along, would most of the bugs that he and his tool found still plague open source distributed systems today? That's a scary thought.

If I knew how to fund more work on correctness, I'd try to convince you that we should switch to this new model, but I don't know of a funding model that works. I've set up a [patreon (donation account)](<https://www.patreon.com/danluu>), but it would be quite extraordinary if that was sufficient to actually fund a signifcant amount of work. If you look at how much programmers make off of donations, if I made two order of magnitude less than I could if I took a job in industry, that would already put me in the top 1% of programmers on patreon. If I made one order of magnitude less than I'd make in industry, that would be extraordinary. Off the top of my head, the only programmers who make more than that off of patreon either make something with much broader appeal (like games) or are Evan You, who makes one of the most widely use front-end libraries in existence. And if I actually made as much as I can make in industry, I suspect that would make me the highest grossing programmer on patreon, even though, by industry standards, my compensation hasn't been anything special.

If I had to guess, I'd say that part of the reason it's hard to fund this kind of work is that consumers don't incentivize companies to fund this sort of work. If you look at "big" tech companies, two of them are substantially more serious about correctness than their competitors. This results in many fewer horror stories about lost emails and documents as well as lost entire accounts. If you look at the impact on consumers, it might be something like the difference between 1% of people seeing lost/corrupt emails vs. 0.001%. I think that's pretty significant if you multiply that cost across all consumers, but the vast majority of consumers aren't going to make decisions based on that kind of difference. If you look at an area where correctness problems are much more apparent, like databases or backups, you'll find that even the worst solutions have defenders who will pop into any dicussions and say "works for me". A backup solution that works 90% of the time is quite bad, but if you have one that works 90% of the time, it will still have staunch defenders who drop into discussions to say things like "I've restored from backup three times and it's never failed! You must be making stuff up!". I don't blame companies for rationally responding to consumers, but I do think that the result is unfortunate for consumers.

Just as an aside, one of the great wonders of doing open work for free is that the more free work you do, the more people complain that you didn't do enough free work. As David MacIver has said, [doing open source work is like doing normal paid work, except that you get paid in complaints instead of cash](<https://www.youtube.com/watch?v=2XCDm3MoXUY>). It's basically guaranteed that the most common comment on this post, for all time, will be that didn't test someone's pet filesystem because we're `btrfs` shills or just plain lazy, even though we include a link to a repo that lets anyone add tests as they please. Pretty much every time I've done any kind of free experimental work, people who obvously haven't read the experimental setup or the source code complain that the experiment couldn't possibly be right because of [thing that isn't true that anyone could see by looking at the setup] and that it's absolutely inexcusable that I didn't run the experiment on the exact pet thing they wanted to see. Having played video games competitively in the distant past, I'm used to much more intense internet trash talk, but in general, this incentive system seems to be backwards.

### Appendix: experimental setup

For the error injection setup, a high-level view of the experimental setup is that [`dmsetup`](<https://stackoverflow.com/q/1870696/334816>) was used to simulate bad blocks on the disk.

A list of the commands run looks something like:
    
    
    cp images/btrfs.img.gz /tmp/tmpeas9efr6.gz
    gunzip -f /tmp/tmpeas9efr6.gz
    losetup -f
    losetup /dev/loop19 /tmp/tmpeas9efr6
    blockdev --getsize /dev/loop19
    #        0 74078 linear /dev/loop19 0
    #        74078 1 error
    #        74079 160296 linear /dev/loop19 74079
    dmsetup create fserror_test_1508727591.4736078
    mount /dev/mapper/fserror_test_1508727591.4736078 /mnt/fserror_test_1508727591.4736078/
    mount -t overlay -o lowerdir=/mnt/fserror_test_1508727591.4736078/,upperdir=/tmp/tmp4qpgdn7f,workdir=/tmp/tmp0jn83rlr overlay /tmp/tmpeuot7zgu/
    ./mmap_read /tmp/tmpeuot7zgu/test.txt
    umount /tmp/tmpeuot7zgu/
    rm -rf /tmp/tmp4qpgdn7f
    rm -rf /tmp/tmp0jn83rlr
    umount /mnt/fserror_test_1508727591.4736078/
    dmsetup remove fserror_test_1508727591.4736078
    losetup -d /dev/loop19
    rm /tmp/tmpeas9efr6
    

[See this github repo for the exact set of commands run to execute tests](<https://github.com/danluu/fs-errors/>).

Note that all of these tests were done on linux, so `fat` means the linux `fat` implementation, not the windows `fat` implementation. `zfs` and `reiserfs` weren’t tested because they couldn’t be trivially tested in the exact same way that we tested other filesystems (one of us spent an hour or two trying to get `zfs` to work, but its configuration interface is inconsistent with all of the filesystems tested; `reiserfs` appears to have a consistent interface but testing it requires doing extra work for a filesystem that appears to be dead). `ext3` support is now provided by the `ext4` code, so what `ext3` means now is different from what it meant in 2005.

All tests were run on both ubuntu 17.04, 4.10.0-37, as well as on arch, 4.12.8-2. We got the same results on both machines. All filesystems were configured with default settings. For `btrfs`, this meant duplicated metadata without duplicated data and, as far as we know, the settings wouldn't have made a difference for other filesystems.

The second part of this doesn’t have much experimental setup to speak of. The setup was to grep the linux source code for the relevant functions.

_Thanks to Leah Hanson, David Wragg, Ben Kuhn, Wesley Aptekar-Cassels, Joel Borggrén-Franck, Yuri Vishnevsky, and Dan Puttick for comments/corrections on this post._

[← UI backwards compatibility](<https://danluu.com/ui-compatibility/>) [Keyboard latency →](<https://danluu.com/keyboard-latency/>)
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
