# NECCDC 2025

> [!NOTE]
> If you have questions about our code or if you are just interested in what the [league](https://neccdl.org/) does **reach out**
>
> In addition to this code there also is a [blog post](https://infrasec.sh/post/neccdc-2025) covering the infrastructure and competition


- [Andrew Aiken](https://github.com/andrew-aiken)
  - Kubernetes
  - InfluxDB
  - Teleport
  - Nginx
  - AWS
- [Andrew Iadevaia](https://github.com/andrewiadevaia)
  - Firewalls
    - pfSense
    - Palo Alto
  - Windows
- [Gerry Normandin](https://github.com/gnormandin)
  - ipSec VPN
- [Justin Marwad](https://github.com/justinmarwad)
  - Graylog
- [Jake White](https://github.com/Cyb3r-Jak3)
  - Discord
- [Evan Soroken](https://github.com/ESoro25)
  - Competition support
- [Jason Gendron](https://github.com/jasongendron)
  - Competition support

## Ansible
This directory contains a majority of the code base for shaping the individual hosts and services within the environment.

#### Inventory
Contains the inventory files necessary for ansible to be able to target multiple teams with a inventory group. Utilizing ansible's [inventory load order](https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html#managing-inventory-load-order) and and a python script we can abstract the creation of the inventory hostvars from individual host -> host groups -> all hosts. To supplement this, an `ansible.cfg` file is included to specify the inventory file to use.

#### Pre
This directory contains all the packer build configurations for the competition. Each host is either broken down into a separate directory or is grouped into a single directory with multiple hosts based on category. The directories contain the necessary packer build configurations, typically within a folder named `packer`, and any necessary provisioning scripts located at the same level as the `packer` folder.

#### Post
This directory contains all configuration and setup tasks for anything that could not be completed in the [Packer](#Pre) stage. The majority of the codebase is Ansible with some special scripts for edge cases ansible could not handle. Similar to the [Pre](#Pre) directory, the [Post](#Post) directory is broken down into individual host directories or grouped into a single directory with multiple hosts based on category.

### Shared
- [black-team](/ansible/shared/black_team) - Tasks to provision a black-team user.
- [blue-team](/ansible/shared/blue_team) - Tasks to provision blue-team users for their respective host.
- [wireguard](/ansible/shared/wireguard) - Tasks to setup wireguard EC2 instance, wg-easy docker containers, and black, blue, and red team certs.

## Scorestack
This directory contains the necessary resources to provision the scorestack engine for the competition. The scorestack engine is provisioned and controlled solely through ansible.

## Terraform
This directory contains the necessary resources to provision the infrastructure for the competition on AWS. Most of the repetition in the codebase is abstracted into modules to make the codebase more maintainable and easier to use.

![](/img/regionals-deploy-path.png)
