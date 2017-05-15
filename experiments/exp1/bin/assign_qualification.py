#!/usr/bin/env python2
from __future__ import print_function
from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter
from boto.mturk.connection import MTurkConnection
import os
from itertools import chain
import pandas as pd

def extract_csv_old(csv):
    df = pd.read_csv(csv, header=None)
    wids = df[2]
    for wid in wids:
        if wid.startswith('A') and 12 < len(wid) < 15:
            yield wid

def extract_csv(csv):
    df = pd.read_csv(csv)
    wids = df['What is your Amazon Worker ID']
    return wids

def extract_txt(txt):
    with open(txt) as f:
        for line in f:
            yield line.strip()


if __name__ == "__main__":
    parser = ArgumentParser(
        formatter_class=ArgumentDefaultsHelpFormatter)
    parser.add_argument(
        "--qualification",
        default='3KSLMSKXULOAUWEIRE3PSPRVZMDMLU',  # Flight Planning Compensation
        metavar="QUALIFICATION",
        help="Qualification id.",
        )
    parser.add_argument(
        "--value",
        default=1,
        type=int,
        help="Qualification score.")
    parser.add_argument(
        "--csv",
        default='',
        type=str,
        help="CSV file containing worker ids.")
    parser.add_argument(
        "--txt",
        default='',
        type=str,
        help="Text file containing worker ids.")
    parser.add_argument(
        '--lower',
        default=False,
        type=bool,
        help='Lower qualification values?'
    )
    parser.add_argument(
        "workers",
        metavar="WORKER",
        nargs="*",
        help="Worker id.")
    args = parser.parse_args()


    print("Connecting to mechanical turk...")
    conn = MTurkConnection(os.environ['AWS_ACCESS_KEY_ID'], os.environ['AWS_SECRET_ACCESS_KEY'])
    # get workers who already have the qualification
    def get_quals():
        results = conn.get_qualifications_for_qualification_type(args.qualification)
        return {x.SubjectId: x.IntegerValue for x in results}

    old_quals = get_quals()

    if args.csv:
        csv_workers = list(extract_csv(args.csv))
        print('Extracted %s workerss from %s' % (len(csv_workers), args.csv))
        input('Press enter to continue')
    else:
        csv_workers = []
    if args.txt:
        txt_workers = list(extract_txt(args.txt))
        print('Extracted %s workerss from %s' % (len(txt_workers), args.txt))
        input('Press enter to continue')
    else:
        txt_workers = []

    for worker in args.workers + csv_workers + txt_workers:
        # if the worker doesn't already have the qualification, then
        # assign it, otherwise just update the qualification score
        qual = old_quals.get(worker)
        if qual is None:
            print("Assigning qualification '%s' to worker '%s'" % (args.qualification, worker))
            result = conn.assign_qualification(args.qualification, worker, args.value)
            if result:
                print(result)
        elif args.lower or args.value > qual:
            print("Updating qualification '%s' for worker '%s'" % (args.qualification, worker))
            result = conn.update_qualification_score(args.qualification, worker, args.value)
            if result:
                print(result)

    # print(out the current set of workers with the qualification)
    new_quals = get_quals()
    print("%d workers with qualification %s:" % (len(new_quals), args.qualification))
    s = pd.Series(new_quals)
    s.to_csv('qualifications.csv')
    print(s.value_counts())
    # for result in results:
        # print("%s (value: %s)" % (result.SubjectId, result.IntegerValue))

