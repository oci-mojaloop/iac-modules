Few points to note

Db service (mysql) parameters are passed via a json file. We dont know exactly how this structure looks like. Based on some assumption we believe it looks like below

```
[
  {
    "resource_name": "db1",
    "external_service": true,
    "resource_type": "mysql",
    "external_resource_config": {
      "db_name": "something",
      "username": "something",
      "password": "kjaslkdjasdlkjas",
      "port": "3306",
      "engine_version": "8.2.0",
      "shape_name": "MySQL.VM.Standard.E4.1.8GB",
      "backup_retention_days": 3,
      "allocated_storage": 50,
      "display_name": "db1",
      "hostname_label": "db1",
      "is_highly_available": false,
      "deletion_protection": true,
      "parameters": [
        {
          "autocommit": true,
          "aslj": null,
          "lasjdlkj": null
        }
      ],
      "options": [
        {
          "abalkjl": "alkjdas",
          "kjasljk": "alkjda",
          "kajlsdjk": "lkasfd"
        }
      ]
    }
  }
]

```

This module is not fully completed as we will have to correct as we do the testing. Especially in terms of module return parameters