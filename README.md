# Logstash Plugin

[![Build Status](https://travis-ci.org/Transrian/logstash-filter-ldap.svg?branch=master)](https://travis-ci.org/Transrian/logstash-filter-ldap)

This is a plugin for [Logstash](https://github.com/elastic/logstash).

It is fully free and fully open source. The license is Apache 2.0, meaning you are pretty much free to use it however you want in whatever way.

## Documentation

**logstash-filter-ldap** filter will add fields queried from a ldap server to the event.
The fields will be stored in a variable called **target**, that you can modify in the configuration file.

If an error occurs during the process tha **tags** array of the event is updated with either:
- **LDAP_ERROR** tag: Problem while connecting to the server: bad *host, port, username, password, or search_dn* -> Check the error message and your configuration.
- **LDAP_NOT_FOUND** tag: Object wasn't found.

If error logging is enabled a field called **error** will also be added to the event.
It will contain more details about the problem.

## Example

### Basic sample

#### Input event

```ruby
{
    "@timestamp" => 2018-02-25T10:04:22.338Z,
    "@version" => "1",
    "myUid" => "u501565"
}
```

#### Logstash filter

```ruby
filter {
  ldap {
    identifier_value => "%{myUid}"
    host => "my_ldap_server.com"
    ldap_port => "389"
    username => "<connect_username>"
    password => "<connect_password>"
    search_dn => "<user_search_pattern>"
  }
}
```

#### Output event

```ruby
{
    "@timestamp" => 2018-02-25T10:04:22.338Z,
    "@version" => "1",
    "myUid" => "u501565",
    "ldap" => {
        "givenName" => "VALENTIN",
        "sn" => "BOURDIER"
    }
}
```

## Parameters availables

Here is a list of all parameters, with their default value, if any, and their description.

|    Option name        | Type    | Required | Default value  | Description                                                                                                   | Example                            |
|:---------------------:|---------|----------|----------------|---------------------------------------------------------------------------------------------------------------|------------------------------------|
| identifier_value      | string  | yes      | n/a            | Identifier of the value to search. If identifier type is uid, then the value should be the uid to search for. | "123456"                           |
| identifier_key        | string  | no       | "uid"          | Type of the identifier to search                                                                              | "uid"                              |
| identifier_type       | string  | no       | "posixAccount" | Object class of the object to search                                                                          | "person"                           |
| search_dn             | string  | yes      | n/a            | Domain name in which search inside the ldap database (usually your userdn or groupdn)                         | "dc=example,dc=org"                |
| attributes            | array   | no       | []             | List of attributes to get. If not set, all attributes available will be get                                   | ['givenName', 'sn']                |
| target                | string  | no       | "ldap"         | Name of the variable you want the result being stocked in                                                     | "myCustomVariableName"             |
| host                  | string  | yes      | n/a            | LDAP server host adress                                                                                       | "ldapserveur.com"                  |
| ldap_port             | number  | no       | 389            | LDAP server port for non-ssl connection                                                                       | 400                                |
| ldaps_port            | number  | no       | 636            | LDAP server port for ssl connection                                                                           | 401                                |
| use_ssl               | boolean | no       | false          | Enable or not ssl connection for LDAP  server. Set-up the good ldap(s)_port depending on that                 | true                               |
| enable_error_logging  | boolean | no       | false          | When there is a problem with the connection with the LDAP database, write reason in the event                 | true                               |
| no_tag_on_failure     | boolean | no       | false          | No tags are added when an error (wrong credentials, bad server, ..) occur                                     | true                               |
| username              | string  | no       | n/a            | Username to use for search in the database                                                                    | "cn=SearchUser,ou=person,o=domain" |
| password              | string  | no       | n/a            | Password of the account linked to previous username                                                           | "123456"                           |
| use_cache             | boolean | no       | true           | Choose to enable or not use of buffer                                                                         | false                              |
| cache_type            | string  | no       | "memory"       | Type of buffer to use. Currently, only one is available, "memory" buffer                                      | "memory"                           |
| cache_memory_duration | number  | no       | 300            | Cache duration (in s) before refreshing values of it                                                          | 3600                               |
| cache_memory_size     | number  | no       | 20000          | Number of object max that the buffer can contains                                                             | 100                                |
| disk_cache_filepath   | string  | no       | nil            | Where the cache will periodically be dumped                                                                     | "/tmp/my-memory-backup"            |
| disk_cache_schedule   | string  | no       | 10m            | Cron period of when the dump of the cache should occured. See [here](https://github.com/floraison/fugit) for the syntax.                           | "10m", "1h", "every day at five", "3h10m"          |

## Buffer

Like all filters, this filter treat only 1 event at a time.
This can lead to some slowing down of the pipeline speed due to the network round-trip time, and high network I/O.

A buffer can be set to mitigate this.

Currently, there is only one basic **"memory"** buffer.

You can enable / disable use of buffer with the option **use_cache**.

### Memory Buffer

This buffer **store** data fetched from the LDAP server **in RAM**, and can be configured with two parameters:
- *cache_memory_duration*: duration (in s) before a cache entry is refreshed if hit.
- *cache_memory_size*: number of tuple (identifier, attributes) that the buffer can contains.

Older cache values than your TTL will be removed from cache.

## Persistant cache buffer

For the only buffer for now, you will be able to save it to disk periodically.

Some specificities :
  - for *the memory cache*, TTL will be reset

Two parameters are required: 
  - *disk_cache_filepath*: path on disk of this backup
  - *disk_cache_schedule*: schedule (every X time unit) of this backup. Please check [here](https://github.com/floraison/fugit) for the syntax of this parameter. 

## Development

If you want to help developing this plugin, you can use the [Vagrantfile](Vagrantfile) to setup your environment.
Requirements :
- [Vagrant](https://www.vagrantup.com/)
- [VirtualBox](https://www.virtualbox.org/)

Here are the steps:

``` bash
# Create the VM, and provision it
vagrant up

# Connect with SSH to the VM
vagrant ssh

# Go inside the project directory
$ cd /vagrant

# Download ruby dependencies
$ bundle install

# Execute tests
$ bundle exec rspec

# Build the Gemfile
$ gem build logstash-filter-ldap.gemspec

# Generate the offline-archive
# You need to install the Logstash yourself
$LOGSTASH_HOME/bin/logstash-plugin install --no-verify logstash-filter-ldap-X.X.X.gem
$LOGSTASH_HOME/bin/logstash-plugin prepare-offline-pack logstash-filter-ldap
```

### Proxy configuration

If you use a proxy, such as a corporate proxy, here are the steps:
- Export your proxy settings: you need to setup these environment variables (even on Windows !):
  - **http_proxy** (eg. http_proxy="http://192.168.0.2:3128/")
  - **https_proxy** (eg. https_proxy="http://192.168.0.2:3128/")
  - **no_proxy** (eg. no_proxy="localhost,127.0.0.1,.example.com")
- Install the Vagrant [proxyconf](https://github.com/tmatilai/vagrant-proxyconf) plugin:
  > vagrant plugin install vagrant-proxyconf

And that's all, all should work!

## Thanks for

This plugin was strongly inspired by the [logstash_filter_LDAPresolve](https://github.com/EricDeveaud/logstash_filter_LDAPresolve), made by [EricDeveaud](https://github.com/EricDeveaud).

## TODO

Instead creating one connection for each event, create only one into the instance class, with a retry number setup into the configuration file.

## Contributing

All contributions are welcome: ideas, patches, documentation, bug reports, complaints, and even something you drew up on a napkin.

Programming is not a required skill. Whatever you've seen about open source and maintainers or community members saying "send patches or die" - you will not see that here.

It is more important to the community that you are able to contribute.

For more information about contributing, see the [CONTRIBUTING](https://github.com/elastic/logstash/blob/master/CONTRIBUTING.md) file.
