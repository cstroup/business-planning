# -*- coding: utf-8 -*-
"""
Created on Wed May  3 17:53:57 2023

@author: P3098826
"""

import paramiko
from paramiko import Transport, SFTPClient, RSAKey

def download_latest_file(hostname, username, password, remote_dir, filename_starts_with):
    # create an SSH transport
    transport = Transport((hostname, 22))
    transport.connect(username=username, password=password)

    # create an SFTP client using the transport
    sftp = SFTPClient.from_transport(transport)
    print("Connection successfully established.")

    # navigate to the remote directory
    sftp.chdir(remote_dir)

    # get a list of files in the remote directory with the specified prefix
    file_list = sftp.listdir()
    matching_files = [f for f in file_list if f.startswith(filename_starts_with)]
    print(matching_files, "\n")

    # find the most recent file and download it
    if len(matching_files) > 0:
        matching_files.sort(key=lambda x: sftp.stat(x).st_mtime, reverse=True)
        latest_file = matching_files[0]
        sftp.get(latest_file, localpath=latest_file)
        print(f"Successfully downloaded {latest_file}")
    else:
        print(f"No files found with prefix '{filename_starts_with}'")

    # close the SFTP client and transport
    sftp.close()
    transport.close()

# example usage
download_latest_file('sdm.charter.com', 'SVCI-erphyperionuat', 'Cv9u\$/k', '/BODS/Business_Planning/Outbound', 'ccv_jea_')
