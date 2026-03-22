+++
title = "The growth of command line options, 1979-Present"
date  = 2020-03-01
[taxonomies]
tags  = ["danluu"]
+++

[My hobby](<https://www.xkcd.com/1795/>): opening up [McIlroy’s UNIX philosophy](<https://danluu.com/mcilroy-unix/>) on one monitor while reading manpages on the other.

The first of McIlroy's dicta is often paraphrased as "do one thing and do it well", which is [shortened from](<https://danluu.com/mcilroy-unix/>) "Make each program do one thing well. To do a new job, build afresh rather than complicate old programs by adding new 'features.'"

McIlroy's example of this dictum is:

> Surprising to outsiders is the fact that UNIX compilers produce no listings: printing can be done better and more flexibly by a separate program.

If you open up a manpage for `ls` on mac, you’ll see that it starts with
    
    
    ls [-ABCFGHLOPRSTUW@abcdefghiklmnopqrstuwx1] [file ...]
    

That is, the one-letter flags to `ls` include every lowercase letter except for `{jvyz}`, 14 uppercase letters, plus `@` and `1`. That’s 22 + 14 + 2 = 38 single-character options alone.

On ubuntu 17, if you read the manpage for coreutils `ls`, you don’t get a nice summary of options, but you’ll see that `ls` has 58 options (including `--help` and `--version`).

To see if `ls` is an aberration or if it's normal to have commands that do this much stuff, we can look at some common commands, sorted by frequency of use.

command| 1979| 1996| 2015| 2017  
---|---|---|---|---  
ls| 11| 42| 58| 58  
rm| 3| 7| 11| 12  
mkdir| 0| 4| 6| 7  
mv| 0| 9| 13| 14  
cp| 0| 18| 30| 32  
cat| 1| 12| 12| 12  
pwd| 0| 2| 4| 4  
chmod| 0| 6| 9| 9  
echo| 1| 4| 5| 5  
man| 5| 16| 39| 40  
which| | 0| 1| 1  
sudo| | 0| 23| 25  
tar| 12| 53| 134| 139  
touch| 1| 9| 11| 11  
clear| | 0| 0| 0  
find| 14| 57| 82| 82  
ln| 0| 11| 15| 16  
ps| 4| 22| 85| 85  
ping| | 12| 12| 29  
kill| 1| 3| 3| 3  
ifconfig| | 16| 25| 25  
chown| 0| 6| 15| 15  
grep| 11| 22| 45| 45  
tail| 1| 7| 12| 13  
df| 0| 10| 17| 18  
top| | 6| 12| 14  
  
This table has the number of command line options for various commands for v7 Unix (1979), slackware 3.1 (1996), ubuntu 12 (2015), and ubuntu 17 (2017). Cells are darker and blue-er when they have more options (log scale) and are greyed out if no command was found.

We can see that the number of command line options has dramatically increased over time; entries tend to get darker going to the right (more options) and there are no cases where entries get lighter (fewer options). 

[McIlroy has long decried the increase in the number of options, size, and general functionality of commands](<https://archive.org/details/DougMcIlroy_AncestryOfLinux_DLSLUG>)1:

> Everything was small and my heart sinks for Linux when I see the size [inaudible]. The same utilities that used to fit in eight k[ilobytes] are a meg now. And the manual page, which used to really fit on, which used to really be a manual _page_ , is now a small volume with a thousand options... We used to sit around in the UNIX room saying "what can we throw out? Why is there this option?" It's usually, it's often because there's some deficiency in the basic design — you didn't really hit the right design point. Instead of putting in an option, figure out why, what was forcing you to add that option. This viewpoint, which was imposed partly because there was very small hardware ... has been lost and we're not better off for it.

Ironically, one of the reasons for the rise in the number of command line options is another McIlroy dictum, "Write programs to handle text streams, because that is a universal interface" (see `ls` for one example of this).

If structured data or objects were passed around, formatting could be left to a final formatting pass. But, with plain text, the formatting and the content are intermingled; because formatting can only be done by parsing the content out, it's common for commands to add formatting options for convenience. Alternately, formatting can be done when the user leverages their knowledge of the structure of the data and encodes that knowledge into arguments to `cut`, `awk`, `sed`, etc. (also using their knowledge of how those programs handle formatting; it's different for different programs and the user is expected to, for example, [know how `cut -f4` is different from `awk '{ print $4 }'`](<https://unix.stackexchange.com/a/132322/261842>)2). That's a lot more hassle than passing in one or two arguments to the last command in a sequence and it pushes the complexity from the tool to the user.

People sometimes say that they don't want to support structured data because they'd have to support multiple formats to make a universal tool, but they already have to support multiple formats to make a universal tool. Some standard commands can't read output from other commands because they use different formats, `wc -w` doesn't handle Unicode correctly, etc. Saying that "text" is a universal format is like saying that "binary" is a universal format.

I've heard people say that there isn't really any alternative to this kind of complexity for command line tools, but people who say that have never really tried the alternative, something like PowerShell. I have plenty of complaints about PowerShell, but passing structured data around and easily being able to operate on structured data without having to hold metadata information in my head so that I can pass the appropriate metadata to the right command line tools at that right places the pipeline isn't among my complaints3.

The sleight of hand that's happening when someone says that we can keep software simple and compatible by making everything handle text is the pretense that text data doesn't have a structure that needs to be parsed4. In some cases, we can just think of everything as a single space separated line, or maybe a table with some row and column separators that we specify ([with some behavior that isn't consistent across tools, of course](<https://unix.stackexchange.com/a/132322/261842>)). That adds some hassle when it works, and then there are the cases where serializing data to a flat text format adds considerable complexity since the structure of data means that simple flattening requires significant parsing work to re-ingest the data in a meaningful way.

Another reason commands now have more options is that people have added convenience flags for functionality that could have been done by cobbling together a series of commands. These go all the way back to v7 unix, where `ls` has an option to reverse the sort order (which could have been done by passing the output to something like `tac` had they written `tac` instead of adding a special-case reverse option).

Over time, more convenience options have been added. For example, to pick a command that originally has zero options, `mv` can move _and_ create a backup (three options; two are different ways to specify a backup, one of which takes an argument and the other of which takes zero explicit arguments and reads an implicit argument from the `VERSION_CONTROL` environment variable; one option allows overriding the default backup suffix). `mv` now also has options to never overwrite and to only overwrite if the file is newer.

`mkdir` is another program that used to have no options where, excluding security things for SELinux or SMACK as well as help and version options, the added options are convenience flags: setting the permissions of the new directory and making parent directories if they don't exist.

If we look at `tail`, which originally had one option (`-number`, telling `tail` where to start), it's added both formatting and convenience options For formatting, it has `-z`, which makes the line delimiter `null` instead of a newline. Some examples of convenience options are `-f` to print when there are new changes, `-s` to set the sleep interval between checking for `-f` changes, `--retry` to retry if the file isn't accessible.

McIlroy says "we're not better off" for having added all of these options but I'm better off. I've never used some of the options we've discussed and only rarely use others, but that's the beauty of command line options — unlike with a GUI, adding these options doesn't clutter up the interface. The manpage can get cluttered, but in the age of google and stackoverflow, I suspect many people just search for a solution to what they're trying to do without reading the manpage anyway.

This isn't to say there's no cost to adding options — more options means more maintenance burden, but that's a cost that maintainers pay to benefit users, which isn't obviously unreasonable considering the ratio of maintainers to users. This is analogous to Gary Bernhardt's comment that it's reasonable to practice a talk fifty times since, if there's a three hundred person audience, the ratio of time spent watching to the talk to time spent practicing will still only be 1:6. In general, this ratio will be even more extreme with commonly used command line tools.

Someone might argue that all these extra options create a burden for users. That's not exactly wrong, but that complexity burden was always going to be there, it's just a question of where the burden was going to lie. If you think of the set of command line tools along with a shell as forming a language, a language where anyone can write a new method and it effectively gets added to the standard library if it becomes popular, where standards are defined by dicta like "write programs to handle text streams, because that is a universal interface", the language was always going to turn into a write-only incoherent mess when taken as a whole. At least with tools that bundle up more functionality and options than is UNIX-y users can replace a gigantic set of wildly inconsistent tools with a merely large set of tools that, while inconsistent with each other, may have some internal consistency.

McIlroy implies that the problem is that people didn't think hard enough, the old school UNIX mavens would have sat down in the same room and thought longer and harder until they came up with a set of consistent tools that has "unusual simplicity". But that was never going to scale, the philosophy made the mess we're in inevitable. It's not a matter of not thinking longer or harder; it's a matter of having a philosophy that cannot scale unless you have a relatively small team with a shared cultural understanding, able to to sit down in the same room.

Many of the main long-term UNIX anti-features and anti-patterns that we're still stuck with today, fifty years later, come from the "we should all act like we're in the same room" design philosophy, which is the opposite of the approach you want if you want to create nice, usable, general, interfaces that can adapt to problems that the original designers didn't think of. For example, it's a common complain that modern shells and terminals lack a bunch of obvious features that anyone designing a modern interface would want. When you talk to people who've written a new shell and a new terminal with modern principles in mind, like Jesse Luehrs, they'll note that a major problem is that the UNIX model doesn't have a good seperation of interface and implementation, which works ok if you're going to write a terminal that acts in the same way that a terminal that was created fifty years ago acts, but is immediately and obviously problematic if you want to build a modern terminal. That design philosophy works fine if everyone's in the same room and the system doesn't need to scale up the number of contributors or over time, but that's simply not the world we live in today.

If anyone can write a tool and the main instruction comes from "the unix philosophy", people will have different opinions about what "[simplicity](<https://twitter.com/hillelogram/status/1174714902151421952>)" or "doing one thing"5 means, what the right way to do things is, and inconsistency will bloom, resulting in the kind of complexity you get when dealing with a wildly inconsistent language, like PHP. People make fun of PHP and javascript for having all sorts of warts and weird inconsistencies, but as a language and a standard library, any commonly used shell plus the collection of widely used *nix tools taken together is much worse and contains much more accidental complexity due to inconsistency even within a single Linux distro and there's no other way it could have turned out. If you compare across Linux distros, BSDs, Solaris, AIX, etc., the amount of accidental complexity that users have to hold in their heads when switching systems dwarfs PHP or javascript's incoherence. The most widely mocked programming languages are paragons of great design by comparison.

To be clear, I'm not saying that I or anyone else could have done better with the knowledge available in the 70s in terms of making a system that was practically useful at the time that would be elegant today. It's easy to look back and find issues with the benefit of hindsight. What I disagree with are comments from Unix mavens speaking today; comments like McIlroy's, which imply that we just forgot or don't understand the value of simplicity, or [Ken Thompson saying that C is as safe a language as any and if we don't want bugs we should just write bug-free code](<https://twitter.com/danluu/status/885214004649615360>). These kinds of comments imply that there's not much to learn from hindsight; in the 70s, we were building systems as effectively as anyone can today; five decades of collective experience, tens of millions of person-years, have taught us nothing; if we just go back to building systems like the original Unix mavens did, all will be well. I respectfully disagree.

### Appendix: memory

Although addressing McIlroy's complaints about binary size bloat is a bit out of scope for this, I will note that, in 2017, I bought a Chromebook that had 16GB of RAM for $300. A 1 meg binary might have been a serious problem in 1979, when a standard Apple II had 4KB. An Apple II cost $1298 in 1979 dollars, or $4612 in 2020 dollars. You can get a low end Chromebook that costs less than 1/15th as much which has four million times more memory. Complaining that memory usage grew by a factor of one thousand when a (portable!) machine that's more than an order of magnitude cheaper has four million times more memory seems a bit ridiculous.

I prefer slimmer software, which is why I optimized my home page down to two packets (it would be a single packet if my CDN served high-level brotli), but that's purely an aesthetic preference, something I do for fun. The bottleneck for command line tools isn't memory usage and spending time optimizing the memory footprint of a tool that takes one meg is like getting a homepage down to a single packet. Perhaps a fun hobby, but not something that anyone should prescribe.

### Methodology for table

Command frequencies were sourced from public command history files on github, not necessarily representative of your personal usage. Only "simple" commands were kept, which ruled out things like curl, git, gcc (which has > 1000 options), and wget. What's considered simple is arbitrary. [Shell builtins](<https://en.wikipedia.org/wiki/Shell_builtin>), like `cd` weren't included.

Repeated options aren't counted as separate options. For example, `git blame -C`, `git blame -C -C`, and `git blame -C -C -C` have different behavior, but these would all be counted as a single argument even though `-C -C` is effectively a different argument from `-C`.

The table counts sub-options as a single option. For example, `ls` has the following:

> \--format=WORD across -x, commas -m, horizontal -x, long -l, single-column -1, verbose -l, vertical -C

Even though there are seven format options, this is considered to be only one option.

Options that are explicitly listed as not doing anything are still counted as options, e.g., `ls -g`, which reads `Ignored; for Unix compatibility.` is counted as an option.

Multiple versions of the same option are also considered to be one option. For example, with `ls`, `-A` and `--almost-all` are counted as a single option.

In cases where the manpage says an option is supposed to exist, but doesn't, the option isn't counted. For example, the v7 `mv` manpage says

> BUGS
> 
> If file1 and file2 lie on different file systems, mv must copy the file and delete the original. In this case the owner name becomes that of the copying process and any linking relationship with other files is lost.
> 
> Mv should take **-f** flag, like rm, to suppress the question if the target exists and is not writable.

`-f` isn't counted as a flag in the table because the option doesn't actually exist.

The latest year in the table is 2017 because I wrote the first draft for this post in 2017 and didn't get around to cleaning it up until 2020.

### Related

[mjd on the Unix philosophy, with an aside into the mess of /usr/bin/time vs. built-in time](<https://blog.plover.com/Unix/tools.html>).

[mjd making a joke about the proliferation of command line options in 1991](<https://groups.google.com/forum/m/#!topic/rec.humor.funny/Q-HG4LpW564>).

On HN:

> > p1mrx:
>> 
>> [It's strange that ls has grown to 58 options, but still can't output \0-terminated filenames](<https://unix.stackexchange.com/q/112125/261842>)
>> 
>> As an exercise, try to sort a directory by size or date, and pass the result to xargs, while supporting any valid filename. I eventually just gave up and made my script ignore any filenames containing \n.
> 
> whelming_wave:
> 
> Here you go: sort all files in the current directory by modification time, whitespace-in-filenames-safe. The `printf (od -> sed)' construction converts back out of null-separated characters into newline-separated, though feel free to replace that with anything accepting null-separated input. Granted,`sort --zero-terminated' is a GNU extension and kinda cheating, but it's even available on macOS so it's probably fine.
    
    
          printf '%b' $(
            find . -maxdepth 1 -exec sh -c '
              printf '\''%s %s\0'\'' "$(stat -f '\''%m'\'' "$1")" "$1"
            ' sh {} \; | \
            sort --zero-terminated | \
            od -v -b | \
            sed 's/^[^ ]*//
          s/ *$//
          s/  */ \\/g
          s/\\000/\\012/g')
    

> If you're running this under zsh, you'll need to prefix it with `command' to use the system executable: zsh's builtin printf doesn't support printing octal escape codes for normally printable characters, and you may have to assign the output to a variable and explicitly word-split it.
> 
> This is all POSIX as far as I know, except for the sort.

[The Unix haters handbook](<https://en.wikipedia.org/wiki/The_Unix-Haters_Handbook>).

[Why create a new shell](<http://www.oilshell.org/blog/2018/01/28.html>)?

Thanks to Leah Hanson, Jesse Luehrs, Hillel Wayne, Wesley Aptekar-Cassels, Mark Jason Dominus, Travis Downs, and Yuri Vishnevsky for comments/corrections/discussion. 

* * *

  1. This quote is slightly different than the version I've seen everywhere because I watched [the source video](<https://archive.org/details/DougMcIlroy_AncestryOfLinux_DLSLUG>). AFAICT, every copy of this quote that's on the internet (indexed by Bing, DuckDuckGo, or Google) is a copy of one person's transcription of the quote. There's some ambiguity because the audio is low quality and I hear something a bit different than whoever transcribed that quote heard. [return]
  2. Another example of something where the user absorbs the complexity because different commands handle formatting differently is [time formatting](<https://blog.plover.com/Unix/tools.html>) — the shell builtin `time` is, of course, inconsistent with `/usr/bin/time` and the user is expected to know this and know how to handle it. [return]
  3. Just for example, you can use `ConvertTo-Json` or `ConvertTo-CSV` on any object, you [can use cmdlets to change how properties are displayed for objects](<https://docs.microsoft.com/en-us/powershell/scripting/samples/using-format-commands-to-change-output-view>), and you can write formatting configuration files that define how you prefer things to be formatted.

Another way to look at this is through the lens of [Conway's law](<https://en.wikipedia.org/wiki/Conway's_law>). If we have a set of command line tools that are built by different people, often not organizationally connected, the tools are going to be wildly inconsistent unless someone can define a standard and get people to adopt it. This actually works relatively well on Windows, and not just in PowerShell.

A common complaint about Microsoft is that they've created massive API churn, often for non-technical organizational reasons (e.g., a Sinofsky power play, like the one described in the replies to the now-deleted Tweet at <https://twitter.com/stevesi/status/733654590034300929>). It's true. Even so, from the standpoint of a naive user, off-the-shelf Windows software is generally a lot better at passing non-textual data around than *nix. One thing this falls out of is Windows's embracing of non-textual data, which goes back at least to [COM](<https://en.wikipedia.org/wiki/Component_Object_Model>) in 1999 (and arguably OLE and DDE, released in 1990 and 1987, respectively).

For example, if you copy from Foo, which supports binary formats `A` and `B`, into Bar, which supports formats `B` and `C` and you then copy from Bar into Baz, which supports `C` and `D`, this will work even though Foo and Baz have no commonly supported formats. 

When you cut/copy something, the application basically "tells" the clipboard what formats it could provide data in. When you paste into the application, the destination application can request the data in any of the formats in which it's available. If the data is already in the clipboard, "Windows" provides it. If it isn't, Windows gets the data from the source application and then gives to the destination application and a copy is saved for some length of time in Windows. If you "cut" from Excel it will tell "you" that it has the data available in many tens of formats. This kind of system is pretty good for compatibility, although it definitely isn't simple or minimal.

In addition to nicely supporting many different formats and doing so for long enough that a lot of software plays nicely with this, Windows also generally has nicer clipboard support out of the box.

Let's say you copy and then paste a small amount of text. Most of the time, this will work like you'd expect on both Windows and Linux. But now let's say you copy some text, close the program you copied from, and then paste it. A mental model that a lot of people have is that when they copy, the data is stored in the clipboard, not in the program being copied from. On Windows, software is typically written to conform to this expectation (although, technically, users of the clipboard API don't have to do this). This is less common on Linux with X, where the correct mental model for most software is that copying stores a pointer to the data, which is still owned by the program the data was copied from, which means that paste won't work if the program is closed. When I've (informally) surveyed programmers, they're usually surprised by this if they haven't actually done copy+paste related work for an application. When I've surveyed non-programmers, they tend to find the behavior to be confusing as well as surprising.

The downside of having the OS effectively own the contents of the clipboard is that it's expensive to copy large amounts of data. Let's say you copy a really large amount of text, many gigabytes, or some complex object and then never paste it. You don't really want to copy that data from your program into the OS so that it can be available. Windows also handles this reasonably: applications can [provide data only on request](<https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-rdpeclip/fa309d1b-8034-44bf-b927-adfc753e69c1>) when that's deemed advantageous. In the case mentioned above, when someone closes the program, the program can decide whether or not it should push that data into the clipboard or discard it. In that circumstance, a lot of software (e.g., Excel) will prompt to "keep" the data in the clipboard or discard it, which is pretty reasonable.

It's not impossible to support some of this on Linux. For example, [the ClipboardManager spec](<https://freedesktop.org/wiki/ClipboardManager/>) describes a persistence mechanism and GNOME applications generally kind of sort of support it (although [there are some bugs](<https://bugzilla.gnome.org/show_bug.cgi?id=510204#c8>)) but the situation on *nix is really different from the more pervasive support Windows applications tend to have for nice clipboard behavior.

[return]
  4. Another example of this are tools that are available on top of modern compilers. If we go back and look at McIlroy's canonical example, how proper UNIX compilers are so specialized that listings are a separate tool, we can see that this has changed even if there's still a separate tool you can use for listings. Some commonly used Linux compilers have literally thousands of options and do many things. For example, one of the many things `clang` now does is static analysis. As of this writing, [there are 79 normal static analysis checks and 44 experimental checks](<https://clang.llvm.org/docs/analyzer/checkers.html#default-checkers>). If these were separate commands (perhaps individual commands or perhaps a `static_analysis` command, they'd still rely on the same underlying compiler infrastructure and impose the same maintenance burden — it's not really reasonable to have these static analysis tools operate on plain text and reimplement the entire compiler toolchain necessary to get the point where they can do static analysis. They could be separate commands instead of bundled into `clang`, but they'd still take a dependency on the same machinery that's used for the compiler and either impose a maintenance and complexity burden on the compiler (which has to support non-breaking interfaces for the tools built on top) or they'd break all the time.

Just make everything text so that it's simple makes for a nice soundbite, but in reality the textual representation of the data is often not what you want if you want to do actually useful work.

And on clang in particular, whether you make it a monolithic command or thousands of smaller commands, clang simply does more than any compiler that existed in 1979 or even all compilers that existed in 1979 combined. It's easy to say that things were simpler in 1979 and that us modern programmers have lost our way. It's harder to actually propose a design that's actually much simpler and could really get adopted. It's impossible that such a design could maintain all of the existing functionality and configurability and be as simple as something from 1979.

[return]
  5. Since its inception, curl has gone from supporting 3 protocols to 40. Does that mean it does 40 things and it would be more "UNIX-y" to split it up into 40 separate commands? Depends on who you ask. If each protocol were its own command, created and maintained by a different person, we'd be in the same situation we are with other commands. Inconsistent command line options, inconsistent output formats despite it all being text streams, etc. Would that be closer to the simplicity McIlroy advocates for? Depends on who you ask. [return]


[← How (some) good corporate engineering blogs are written](<https://danluu.com/corp-eng-blogs/>) [Suspicious discontinuities →](<https://danluu.com/discontinuities/>)
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
