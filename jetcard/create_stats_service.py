import argparse
import getpass
import os

STATS_SERVICE_TEMPLATE = """
[Unit]
Description=JetCard stats display service

[Service]
Type=simple
User=%s
ExecStart=/bin/sh -c "python3 -m jetcard.stats"
WorkingDirectory=%s
Restart=always

[Install]
WantedBy=multi-user.target
"""

STATS_SERVICE_NAME = 'jetcard_stats'


def get_stats_service():
    return STATS_SERVICE_TEMPLATE % (getpass.getuser(), os.environ['HOME'])


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--output', default='jetcard_stats.service')
    args = parser.parse_args()

    with open(args.output, 'w') as f:
        f.write(get_stats_service())
