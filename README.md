# Nodebucks API
> Master of your own nodes.
---

Node Bucks is a web application with a Rails API only backend and React/Redux front end.
- Ruby 2.5.1
- Rails 5.2
- PostgreSQL 10.1
- Redis 4.0.8

---
## Requirements
This section assumes you have MacOS. If not, replicate steps appropriate for your OS.

### Install required packages
```
$ brew tap homebrew/cask
$ brew install rbenv ruby-build postgresql redis watchman
$ brew cask install chromedriver
```

### Update your ruby version
```
$ rbenv build 2.5.1
```
### Start required services
```
$ brew services start postgresql
$ brew services start redis
```

## Setup
__Initialize Project__

Clone the project if you have not yet
```
$ git clone git@github.com:rolme/nodebucksapi.git
$ cd nodebucksapi
~/nodebucksapi $ bundle
~/nodebucksapi $ rails db:reload
```

__Start Project__

```
~/project/nodebucksapi $ rake start
```
The application should automatically start or you can visit it here:
Visit: [https://localhost:8081](https://localhost:8081)

## Monitoring & Analytics
To see the Redis Queue (Sidekiq) go here: [https://rency-sidekiq.herokuapp.com/queues](https://rency-sidekiq.herokuapp.com/queues)
Talk to admin to request access

## Installing chromedriver on Windows

1. [Download chromedriver_win32.zip](http://chromedriver.chromium.org/downloads)
2. Create a folder and move there **chromedriver.exe** file from downloaded .zip
3. In order to put ChromeDriver location in your PATH environment variable do as follows:

    **Right click computer > properties > system properties > Advanced > System properties > select Path below > edit > add the path of the folder, where you put chromedriver.exe**
