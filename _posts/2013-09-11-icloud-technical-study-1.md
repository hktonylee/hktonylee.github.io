---
layout: post
title: iCloud Technical Study 1
date: 2013-09-11
tags: icloud apple
---

![iCloud Logo]({{ site.url }}/assets/2013/09/11/iCloudLogo.png)

iCloud, the main focus of Apple in the coming decade, is undoubtedly one of the most complex cloud infrastructure in this world. The technical details of iCloud is not well known outside Apple. Plus I am an Apple fans (yeah!). I feel like unavoidable to study its architecture and present it to all of you.

# Start point

iCloud has various clients, like iOS, Mac and Web. It is rather difficult to crack the iOS and Mac at first without any prior knowledge. The encryption and the unreadable assembly make this task even harder. So I choose to study the iCloud in the web first. The task becomes quite easy if you can use the inspector of modern browser (all but Internet Explorer, LOL).

# Result

I present the result only because it is more interesting than the technical details ;-) The investigation procedure is quite boring if your are not geek.

Well, geeks play things differently.

## iCloud Topology

This part is about the topology of iCloud. The main web entry point of iCloud is [http://icloud.com](http://icloud.com). This will redirect you to the secure iCloud ([https://www.icloud.com](https://www.icloud.com)) in no time.

You may be curious about the service provider of iCloud. Yes the iCloud infrastructure is bought to you by Akamai. She is one of the largest CDN companies in this world. And iCloud uses her DNS and CDN services. The core iCloud service is hosted somewhere in Cupertino. The ISP is Verizon Enterprise Solutions Worldwide.

The secure iCloud homepage is basically a HTML page. It is distributed via the CDN of Akamai. If you visit iCloud in Hong Kong, it will send you the iCloud files from Japan. Because the nearest CDN server is located therein.

The iCloud infrastructure is made up of these components:

### Web Services for Human

- Contacts web service ([https://p04-contactsws.icloud.com:443](https://p04-contactsws.icloud.com:443))
- Calendar web service ([https://p04-calendarws.icloud.com:443](https://p04-calendarws.icloud.com:443))
- Reminders web service ([https://p04-remindersws.icloud.com:443](https://p04-remindersws.icloud.com:443))
- Mail web service ([https://p04-mailws.icloud.com:443](https://p04-mailws.icloud.com:443))
- Notes web service ([https://p04-notesws.icloud.com:443](https://p04-notesws.icloud.com:443))

### Web Services for Computer

- iCloud storage web service ([https://p04-ubiquityws.icloud.com:443](https://p04-ubiquityws.icloud.com:443))
- Key-value Service ([https://p04-keyvalueservice.icloud.com:443](https://p04-keyvalueservice.icloud.com:443))
- Push web service ([https://p04-pushws.icloud.com:443](https://p04-pushws.icloud.com:443))

### Applications

- iWork ([https://p04-iwmb.icloud.com:443](https://p04-iwmb.icloud.com:443))

### Support

- Account ([https://p04-setup.icloud.com:443](https://p04-setup.icloud.com:443))
- Streams ([https://p04-streams.icloud.com:443](https://p04-streams.icloud.com:443))
- Find me ([https://p04-fmipweb.icloud.com:443](https://p04-fmipweb.icloud.com:443))

Fun fact: all of these services have IP `17.158.28.xx`. This subnet is specially made for iCloud ;-)

As you see most of them are actually the iOS app. Don’t worry. We will visit all (umm…) of them in the future.

In the next blog, I will show you the logical components of the iCloud, which is named “CloudOS”. Can you feel the bright future of iCloud now?

## Partitions

As you see the servers URL are prefixed with p04. I guess the “p” stands for “partition”, although I can’t find any Apple documents describing this term. In the later of the study I will keep using it.

## Geolocations of the partitions

After investigation, the iCloud are divided into 22 partitions (from p01 to p22). All of them are distributed in US. They are divided into 3 data centers. The last ICMP-enabled hops have IP:

1. `152.179.48.38` (Partitions 03, 04, 07 and 08)
	- Location: Maybe San Jose, California
	- ISP: Ans Communications Inc
2. `66.151.128.62` (Partitions 10, 12, 14, 16, 18, 20 and 22)
	- Location: Maybe San Jose, California
	- ISP: Internap Network Services Corporation
3. `67.106.215.34` (Partitions 01, 02, 05, 06, 09, 11, 13, 15, 17, 19 and 21)
	- Location: Maybe Virginia
	- ISP: Xo Communications

The geolocations are checked with IP Location. The location is somewhat correct because Cupertino, where the Apple’s headquarter locates, is near San Jose. I will later find a better way to verify the geolocations.

# Summary

A picture is worth a thousand words. So I will make a summery graph which describes the above text. I promise it is coming. Stay tuned ;-)


