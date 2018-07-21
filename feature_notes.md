# Idea

- every time someone from outside your unit signs you up for something, send an email, except for the common house

# Other

- Comomon House Cleaning
- Only allow signup up for stuff 6 months in advance

# Problems

1.  people forget to enter meal costs
2.  people accidently sign up other people to cook / eat
3.  handling reconciliation is a pain
4.  people forget to sign up for a rotation

# Solutions

1.  Steps:

- send 3 weekly reminder emails
- autofill amount
  - community decided
  - average
  - meal becomes free

# Issues

- automatically refreshing the page when there's a new version of the app
  - have service worker check for a new version every 5 min
- not filling up IndexedDB
  - have service worker iterate through items in indexeddb,
    deleting all that were fetched more than a month ago
- automatically checking for new data if the computer has been asleep for awhile
- detecting calendar updates
