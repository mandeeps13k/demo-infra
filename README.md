## Infrastructure for demo Django Application

This repository can be used to deploy Infrastructure for demo Django Application.


The Given Terraform Project implements/Creates the following Infrastructure in an AWS Account::

- An AWS Key Pair (named `example_keypair`) by taking input of your Public Key, this AWS Key pair will be used later for accessing an ec2 instance. The Public Key is being configured as a Project secret in Repository.
- An AWS Security Group named `https-access-sg` which allows only INGRESS traffic on port 443 (https) and egress on 3306 for accessing RDS Database.
- An AWS ec2 Instance which has keyname configured for `example_keypair` and SecurityGroup as `https-access-sg`.
- An AWS KMS Key for Encryption of RDS Database with rotation of key enabled.
- A SecurityGroup for RDS Database which allows Ingress only on port 3306 and only from the ec2 Instance created in the previous step.
- An AWS RDS Database Instance with `engine` configured as `mysql` and `engine_class` configured as `db.t3.micro` , Password for this RDS Database is configured as a Secret, `db_name` configured as `demo`
- The RDS Database instance `demo` has logging enabled with Logs exported to cloudwatch Logs group 
- The RDS Database instance `demo` uses the previously created kms Key for encrpytion of RDS storage. RDS uses the industry standard AES-256 encryption algorithm to encrypt.
- Logging is configured for this RDS Databse Instance options set for `enabled_cloudwatch_logs_exports`. The Logs are available in corresponsing Cloudwatch Log Groups.
- 
