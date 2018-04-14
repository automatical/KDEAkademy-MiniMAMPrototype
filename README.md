# KDEAkademy - Mini MAM - PROTOTYPE

This repository contains a quick and nasty mini-mam intended to prove the technical feasability of some of our theories regarding video capture for Akademy 2018.

Given that this project is a prototype, there is very little in terms of code quality

### The Problem

In previous years, it has often taken weeks, if not months to pull together all of the necessery assets to provide the final edited copies of each of the Akademy Videos.

Can we, using our Voctomix based video infrastructure - deliver talk recordings within a few hours of capture using limited manpower, compute resources and time.

## Technology

A set of scripts that should import talk definitions from Frab into RethinkDB
Jobs should be created on the creation and update of each talk that will generate custom intro and outro videos for each event
A Rails based UI that can display information on queued and running jobs, alongside some video metadata.
A file storage watching mechanism that will queue ingest once a file is no longer growing
A set of scripts to generate HLS proxy copies for each asset
An HLS stitcher that can join recordings together against the event schedule, alongside the intros and outros for each event

## Future Plans

Now that we have proven that this mechanism will in fact work, work has begun to build a higher quality application using appropriate (and performant) technologies. This will be linked to from here once this is ready to show.