from urllib import request, parse
import subprocess
from bs4 import BeautifulSoup
import re
import json
import configparser
import logging
import semver

config = configparser.ConfigParser()
config.read("config.ini")

LOG_LEVEL = int(config["logging"]["debug"])
if LOG_LEVEL:
    logging.basicConfig(level=logging.DEBUG)

SDK_BASE_URL = config["nrf-sdk"]["BaseURL"]
SDK_DOCKER_REPO = config["nrf-sdk"]["DockerRepo"]
BUILD_DOCKER_REPO = config["nrf-sdk"]["BuildDockerRepo"]

LIST_TAGS_URL = "https://registry.hub.docker.com/v1/repositories/{}/tags"


def run_shell_command(command):
    subprocess.run(command, shell=True, check=True)


def build_base_docker_image(name, download_url):
    logging.info("Building {}".format(name))
    cmd = "docker build --cache-from={} --build-arg DOCKER_HUB=\"{}\" --build-arg download_url=\"{}\" -t \"{}\" .".format(
        name, SDK_DOCKER_REPO, download_url, name)
    logging.info(cmd)
    run_shell_command(cmd)


def build_builder_docker_image(name):
    logging.info("Building {}".format(name))
    cmd = "docker build -f Build.dockerfile --cache-from={} -t \"{}\" .".format(
        name, name)
    logging.info(cmd)
    run_shell_command(cmd)


def build_builder():
    build_tag = "{}:latest".format(BUILD_DOCKER_REPO)
    pull_image(build_tag)
    build_builder_docker_image(build_tag)
    tag_image_as_latest(build_tag, BUILD_DOCKER_REPO)
    publish_docker_image(build_tag)
    publish_docker_image("{}:latest".format(BUILD_DOCKER_REPO))


def pull_image(build_tag):
    cmd = "docker pull {}".format(build_tag)
    logging.info(cmd)
    run_shell_command(cmd)


def pull_if_exists(existing, tag, build_tag):
    try:
        if list(existing).index(tag) >= 0:
            pull_image(build_tag)
        pass
    except ValueError:
        pass


def tag_image_as_latest(build_tag, hub_repo):
    cmd = "docker tag {} {}:latest".format(build_tag, hub_repo)
    logging.info(cmd)
    run_shell_command(cmd)


def publish_docker_image(image):
    logging.info("Publishing {}".format(image))
    run_shell_command("docker push {}".format(image))


def delete_docker_image(image):
    logging.info("Deleting {}".format(image))
    run_shell_command("docker rmi -f {}".format(image))


def list_repo_tags(image):
    url = LIST_TAGS_URL.format(image)
    tags_obj = json.load(request.urlopen(url))
    logging.info("{} tags built in {} repo".format(len(tags_obj), image))
    return list(map(lambda tag: tag["name"], tags_obj))


def get_nrf_sdk_downloads():
    folders_page = BeautifulSoup(request.urlopen(
        SDK_BASE_URL), features="html.parser")
    folder_links = []

    for a in folders_page.find_all("a", href=True):
        link = a["href"]
        if re.search(r"SDK_v\d+\.x\.x", link, re.IGNORECASE):
            folder_links.append(link)

    downloads = dict()
    for link in folder_links:
        folder_url = parse.urljoin(SDK_BASE_URL, link)
        folder_page = BeautifulSoup(request.urlopen(
            folder_url), features="html.parser")
        for a in folder_page.find_all("a", href=True):
            sdk_url = a["href"]
            match = re.search(r"SDK_([\d\.]+)_[a-z0-9]{7}\.zip", sdk_url,
                              re.IGNORECASE) or re.search(
                r"sdk_v([\d_]+)_[a-z0-9]{5}\.zip", sdk_url, re.IGNORECASE)
            if match:
                version = match.group(1).strip("_").replace("_", ".")
                download_link = parse.urljoin(folder_url, sdk_url)
                downloads[version] = download_link

    logging.info(
        "Found {} versions of nrf sdk available".format(len(downloads)))

    return downloads


def main():
    sdk_built_tags = list_repo_tags(SDK_DOCKER_REPO)
    build_built_tags = list_repo_tags(BUILD_DOCKER_REPO)

    sdk_downloads = get_nrf_sdk_downloads()
    finished_builds = []
    latest = list(sdk_downloads.keys())[0]
    for tag in sdk_downloads.keys():
        if semver.compare(tag, latest) > 0:
            latest = tag

    build_builder()


    for tag in list(set(sdk_downloads.keys())):
        build_tag = "{}:{}".format(SDK_DOCKER_REPO, tag)
        pull_if_exists(sdk_built_tags, tag, build_tag)
        build_base_docker_image(build_tag, sdk_downloads[tag])
        if tag == latest:
            tag_image_as_latest(build_tag, SDK_DOCKER_REPO)
            publish_docker_image("{}:latest".format(SDK_DOCKER_REPO))
        publish_docker_image(build_tag)
        finished_builds.append(build_tag)

    map(delete_docker_image, finished_builds)


main()
