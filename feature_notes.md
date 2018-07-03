# Idea

- every time someone from outside your unit signs you up for something, send an email, except for the common house

# Features

- more robust authorization
- better way to do common house login
- single page app

# Other

Comomon House Cleaning

- unit
- date
- community
- reminder 1 week before
  Add query params to calendar for url month navigation

# Problems

1.  people forget to enter meal costs
2.  people accidently sign up other people to cook / eat
3.  handling reconciliation is a pain

- people need to give me checks
- i need to deposit them
- i need to write people checks

4.  people forget to sign up for a rotation

# Solutions

1.  Steps:

- send 3 weekly reminder emails
- autofill amount
  - community decided
  - average
  - meal becomes free

# Improve Performance

- always have current, next, previous meals downloaded
- display old calendar data until the new stuff has been fetched

# Issues

- automatically refreshing the page when there's a new version of the app
  - have service worker check for a new version every 5 min
- not filling up IndexedDB
  - have service worker iterate through items in indexeddb,
    deleting all that were fetched more than a month ago
- ## automatically checking for new data if the computer has been asleep for awhile
- detecting calendar updates
- caching calendar data fetches

# Solved

- detecting meal updates while online
- left / right buttons should be disabled during load

Issue: meals not loading
Solution: react-big-calendar

Issue: app not loading on old browsers
Solution #1: feature detect & warn
Solution #2: native apps
Solution #3: polyfill

Issue: Serviceworker messes with redirect
Solution:

Issue: offline cache will eventually fill up
Solution:

# HEROKU APP

admin
api

# SPA

www
swans, etc.

""
