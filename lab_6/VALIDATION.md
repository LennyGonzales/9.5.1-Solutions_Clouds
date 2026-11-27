# Lab 6 : tests de validation

Endpoint RDS : `student-12-5-labdb.c7ssywii2rpq.eu-west-3.rds.amazonaws.com`

## 1. SSH dans le bastion

```bash
cd lab_6/bastion
terraform output ssh_command
ssh -i ~/.ssh/id_ed25519 ec2-user@<BASTION_IP>
```

Sur le bastion :

```bash
psql --version                 # PostgreSQL 14.x
ls -l ~/connect-db.sh          # script présent
aws sts get-caller-identity    # assumed-role/student_12_5_bastion
```

## 2. Script de connexion

```bash
./connect-db.sh                # prompt : labdb=>
```

```sql
\conninfo
SELECT version();
```

## 3. Créer une table et insérer des données

```sql
CREATE TABLE students (
  id         SERIAL PRIMARY KEY,
  name       TEXT NOT NULL,
  role       CHAR(1) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

INSERT INTO students (name, role) VALUES ('Student A', 'A'), ('Student B', 'B');

SELECT * FROM students;
\dt
\q
```

## 4. Persistance des données

Déconnexion / reconnexion :

```bash
exit
ssh -i ~/.ssh/id_ed25519 ec2-user@<BASTION_IP>
echo "SELECT * FROM students;" | ./connect-db.sh
```

Recréation complète du bastion (depuis le Mac, dans `lab_6/bastion`) :

```bash
terraform apply -replace=aws_instance.bastion
terraform output ssh_command
ssh -i ~/.ssh/id_ed25519 ec2-user@<NOUVELLE_IP>
echo "SELECT * FROM students;" | ./connect-db.sh    # les 2 lignes sont toujours là
```

## 5. Tests de sécurité

### a) Sans la règle SG RDS ← bastion

Dans `lab_6/network_rds/terraform.tfvars`, commenter la ligne :

```hcl
# bastion_sg_id = "sg-07ae67fa16b5e03e4"
```

```bash
cd lab_6/network_rds
terraform apply                # 1 to destroy
```

Sur le bastion :

```bash
PGCONNECT_TIMEOUT=5 ./connect-db.sh                # timeout expired
timeout 5 bash -c '</dev/tcp/student-12-5-labdb.c7ssywii2rpq.eu-west-3.rds.amazonaws.com/5432' && echo OUVERT || echo FERMÉ
```

Remettre la ligne, puis :

```bash
terraform apply                # 1 to add
```

### b) RDS non accessible depuis Internet (depuis le Mac)

```bash
host student-12-5-labdb.c7ssywii2rpq.eu-west-3.rds.amazonaws.com          # IP privée 192.168.x.x
nc -zv -G 5 student-12-5-labdb.c7ssywii2rpq.eu-west-3.rds.amazonaws.com 5432   # échec
```

### c) Moindre privilège IAM (sur le bastion)

```bash
aws ssm get-parameter --region eu-west-3 --name /lab6/db/student_1_4/password --with-decryption   # AccessDenied
aws s3 ls                                                                                         # AccessDenied
```

## 6. Nettoyage (dans cet ordre)

```bash
# 1. Retirer la règle RDS (commenter bastion_sg_id dans network_rds/terraform.tfvars)
cd lab_6/network_rds && terraform apply

# 2. Détruire le bastion
cd ../bastion && terraform destroy

# 3. Détruire RDS
cd ../network_rds && terraform destroy
```
