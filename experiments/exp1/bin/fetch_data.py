#!/usr/bin/env python2

import os
import logging
import urllib2
import pandas as pd
from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter

logging.basicConfig(level="INFO")
DATA_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "data/{}/human_raw")


def add_auth(url, username, password):
    """Add HTTP authencation for opening urls with urllib2.

    Based on http://www.voidspace.org.uk/python/articles/authentication.shtml

    """

    # this creates a password manager
    passman = urllib2.HTTPPasswordMgrWithDefaultRealm()

    # because we have put None at the start it will always use this
    # username/password combination for urls for which `theurl` is a
    # super-url
    passman.add_password(None, url, username, password)

    # create the AuthHandler
    authhandler = urllib2.HTTPBasicAuthHandler(passman)

    # All calls to urllib2.urlopen will now use our handler Make sure
    # not to include the protocol in with the URL, or
    # HTTPPasswordMgrWithDefaultRealm will be very confused.  You must
    # (of course) use it when fetching the page though.
    opener = urllib2.build_opener(authhandler)
    urllib2.install_opener(opener)


def fetch(site_root, filename, experiment, version, force=False):
    """Download `filename` from `site_root` and save it in the
    human-raw/`experiment` data folder.

    """

    # get the url
    url = os.path.join(site_root, version, filename)

    # get the destination to save the data, and don't do anything if
    # it exists already
    dest = os.path.join(DATA_PATH.format(experiment), version, "%s.csv" % os.path.splitext(filename)[0])
    if os.path.exists(dest) and not force:
        print('{} already exists. Use --force to overwrite.'.format(dest))
        return

    # try to open it
    try:
        handler = urllib2.urlopen(url)
    except IOError as err:
        if getattr(err, 'code', None) == 401:
            logging.error("Server authentication failed.")
            raise err
        else:
            raise

    # download the data
    data = handler.read()
    logging.info("Fetched succesfully: %s", url)

    # make the destination folder if it doesn't exist
    if not os.path.exists(os.path.dirname(dest)):
        os.makedirs(os.path.dirname(dest))

    # write out the data file
    with open(dest, "w") as fh:
        fh.write(data)
    logging.info("Saved to '%s'", os.path.relpath(dest))
    if filename == 'questiondata':
        df = pd.read_csv(dest, header=None)
        n_pid = df[0].unique().shape[0]
        logging.info('Number of participants: %s', n_pid)


if __name__ == "__main__":
    parser = ArgumentParser(
        formatter_class=ArgumentDefaultsHelpFormatter)
    parser.add_argument(
        '-e', '--experiment',
        default='1',
        help='Directory in data/ to put the results.')
    parser.add_argument(
        "-v", "--version",
        required=True,
        help="Experiment version. This corresponds to the experiment_code_version parameter in the psiTurk config.txt file that was used when the data was collected.")
    parser.add_argument(
        "-a", "--address",
        default="http://cocosci-mcrl.dreamhosters.com/data",
        help="Address from which to fetch data files.")
    parser.add_argument(
        "-u", "--user",
        default=None,
        help="Username to authenticate to the server.")
    parser.add_argument(
        "-p", "--password",
        default=None,
        help="Password to authenticate to the server.")
    parser.add_argument(
        "-f", "--force",
        action="store_true",
        default=False,
        help="Force existing data to be overwritten.")

    args = parser.parse_args()

    # prompt for the username if it wasn't given
    if args.user is None:
        username = 'fredcallaway'
    else:
        username = args.user

    # prompt for the password if it wasn't given
    if args.password is None:
        password = 'cocotastic90'
    else:
        password = args.password

    # create the authentication handler to the server
    add_auth(args.address, username, password)

    # fetch and save the data files
    files = ["trialdata", "eventdata", "questiondata"]
    for filename in files:
        fetch(args.address, filename, args.experiment, args.version, args.force)
