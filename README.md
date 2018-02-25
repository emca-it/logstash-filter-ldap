# Logstash Plugin

This is a plugin for [Logstash](https://github.com/elastic/logstash).

It is fully free and fully open source. The license is Apache 2.0, meaning you are pretty much free to use it however you want in whatever way.

## Documentation

**logstash-filter-ldap** filter will add to the event event fields specifield from a ldap server, with the informations specifieds. Fields will be stored in a variable called **target**, that you can modify in the configuration file

If there are no error during process, than no error tag is set ; otherwise, there could have been, in the **tags** array :
- **LDAP_ERR_CONN**: Problem while connecting to the server : bad *host, port, username or password*
- **LDAP_ERR_FETCH**: Problem while fetching information from the server, probably bad *userdn*
- **LDAP_UNK_USER**: User probably wasn't found
- **LDAP_BAD_BUFF**: The buffer type you selected wasn't found

If so, a field called **error** will be add to the event, with more details about the problem met.

## Example

### Basic sample

#### Input evenement

```
{
    "@timestamp" => 2018-02-25T10:04:22.338Z,
    "@version" => "1",
    "myUid" => "u501565"
}
```

#### Logstash filter

```
filter {
  ldap {
    identifier_value => "u501565"
    host => "my_ldap_server.com"
    ldap_port => "389"
    username => "connect_username"
    password => "connect_password"
    userdn => "user_search_pattern"
  }
}
```

#### Output evenement

```
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

## Full parameters availables

Here is a list of all parameters, with their default value, if any, and their description

|    Option name    | Type    | Required | Default value       | Description                                                                                                   | Example                            |
|:-----------------:|---------|----------|---------------------|---------------------------------------------------------------------------------------------------------------|------------------------------------|
| identifier_value  | string  | yes      | n/a                 | Identifier of the value to search. If identifier type is uid, then the value should be the uid to search for. | "123456"                           |
| identifier_key    | string  | no       | "uid"               | Type of the identifier to search                                                                              | "uid"                              |
| identifier_type   | string  | no       | "posixAccount"      | Object class of the object to search                                                                          | "person"                           |
| attributes        | array   | no       | ['givenName', 'sn'] | List of attributes to get                                                                                     | ['region', 'dn', 'mail']           |
| target            | string  | no       | "ldap"              | Name of the variable you want the result being stocked in                   | "myCustomVariableName"           |
| host              | string  | yes      | n/a                 | LDAP server host adress                                                                                       | "ldapserveur.com"                  |
| ldap_port         | number  | no       | 389                 | LDAP server port for non-ssl connection                                                                       | 400                                |
| ldaps_port        | number  | no       | 636                 | LDAP server port for ssl connection                                                                           | 401                                |
| use_ssl           | boolean | no       | false               | Enable or not ssl connection for LDAP  server. Set-up the good ldap(s)_port depending on that                 | true                               |
| username          | string  | no       | n/a                 | Username to use for search in the database                                                                    | "cn=SearchUser,ou=person,o=domain" |
| password          | string  | no       | n/a                 | Password of the account linked to previous username                                                           | "123456"                           |
| buffer_type       | string  | no       | "memory"            | Type of buffer to use. Currently, only one is available, "memory" buffer                                      | "memory"                           |
| use_cache         | boolean | no       | true                | Choose to enable or not use of buffer                                                                         | false                              |
| cache_interval    | number  | no       | 300                 | Cache duration (in s) before refreshing values of it                                                          | 3600                               |
| buffer_size_limit | number  | no       | 20000               | Number of object max that the buffer can contains                                                             | 100                                |

## Buffer

As all filters, this filter treat only 1 event at a time, that can lead to some slowing down of the pipeline's speed, and high network I/O.

Due to that, a buffer can be set, with some parameters.

Currently, there is only one basic **"memory"** buffer.

You can enable / disable use of buffer with the option **use_cache**

### Memory Buffer

This buffer **store** data fetched from the LDAP server **in RAM**, and can be configured with two parameters:
- cache_interval: duration (in s) before refresh data ever get
- buffer_size_limit: number of couple (identifier, attributes) that the buffer can contains

## Thanks for

This plugin was strongly inspired by the [logstash_filter_LDAPresolve](https://github.com/EricDeveaud/logstash_filter_LDAPresolve), made by [EricDeveaud](https://github.com/EricDeveaud)

## TODO

Instead creating one connection for each evenement, create only one into the instance class, with a retry number set-up into the configuration file

## Contributing

All contributions are welcome: ideas, patches, documentation, bug reports, complaints, and even something you drew up on a napkin.

Programming is not a required skill. Whatever you've seen about open source and maintainers or community members  saying "send patches or die" - you will not see that here.

It is more important to the community that you are able to contribute.

For more information about contributing, see the [CONTRIBUTING](https://github.com/elastic/logstash/blob/master/CONTRIBUTING.md) file.
