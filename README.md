```markdown
# AWS Web Application with Spring Boot

This project demonstrates the implementation of a Spring Boot web application deployed on AWS. The application uses AWS EC2 for the public-facing service and AWS RDS MySQL database for storing and retrieving product data. The application exposes two endpoints:

- `POST /store-products`: Stores product data in the RDS MySQL database.
- `GET /list-products`: Retrieves the list of products from the database.

## Features

- **EC2 Deployment**: A public-facing EC2 instance serves the Spring Boot application.
- **RDS MySQL Database**: A MySQL database running on a private subnet inside a VPC to store product data.
- **VPC Configuration**: The EC2 instance and RDS database are configured within an AWS VPC for secure network communication.
- **API Endpoints**:
  - `POST /store-products`: Receives a list of products and stores them in the database.
  - `GET /list-products`: Retrieves and returns the list of products from the database.

## Prerequisites

Before running this project, ensure you have the following:

- An AWS account.
- AWS EC2 instance for hosting the Spring Boot application.
- AWS RDS instance running MySQL in a private subnet.
- Terraform to provision AWS resources.
- Docker installed on the EC2 instance.

## Terraform Configuration

Use the Terraform files provided to set up the AWS infrastructure, including the EC2 instance, RDS MySQL database, and VPC setup.

### 1. **Provision AWS Resources**

Use the Terraform files to provision the AWS EC2 instance and RDS MySQL database.

```bash
terraform init
terraform apply
```

This will provision:
- **EC2 instance**: Public-facing server for the Spring Boot application.
- **RDS MySQL instance**: Private RDS instance for storing product data.
- **VPC setup**: Network configuration for secure communication between the EC2 instance and RDS.

**Note**: The RDS MySQL database will be provisioned only after running `terraform apply`.

## EC2 Initialization with Java

After provisioning the EC2 instance with Terraform, follow these steps to set up Java and Docker on the EC2 instance.

### 1. **SSH into EC2 Instance**

SSH into the EC2 instance:

```bash
ssh -i /path/to/your-key.pem ec2-user@<your-ec2-ip>
```

### 2. **Install Java on EC2**

Install Java on the EC2 instance:

```bash
sudo yum install java-1.8.0-openjdk -y
```

Verify the installation:

```bash
java -version
```

### 3. **Install Docker on EC2**

Install Docker on the EC2 instance:

```bash
sudo yum install docker -y
```

Start and enable Docker:

```bash
sudo service docker start
sudo systemctl enable docker
```

Add the `ec2-user` to the Docker group:

```bash
sudo usermod -aG docker ec2-user
```

Log out and log back in for the Docker group changes to take effect.

### 4. **Create MySQL Database in RDS using Docker**

Now that Docker is installed on EC2, we will use Docker to create a MySQL database in RDS. First, you will need to use the AWS CLI to interact with RDS.

- Ensure that your AWS credentials are configured on EC2:

```bash
aws configure
```

Next, use the following command to create the MySQL database in RDS:

```bash
docker run --rm -e MYSQL_ROOT_PASSWORD=<password> -e MYSQL_DATABASE=<database-name> -p 3306:3306 mysql:5.7
```

This will create a MySQL container, which connects to the RDS instance, and initializes the database.

## Spring Boot Application Configuration

Once your RDS MySQL instance is up and running, configure the Spring Boot application to connect to the RDS MySQL database.

### 1. **Update `application.properties`**

In the `src/main/resources/application.properties` file, configure the RDS connection:

```properties
# RDS MySQL Database Configuration
spring.datasource.url=jdbc:mysql://<RDS-endpoint>:3306/<database-name>
spring.datasource.username=<your-username>
spring.datasource.password=<your-password>
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver
spring.datasource.jpa.database-platform=org.hibernate.dialect.MySQL5InnoDBDialect
spring.jpa.hibernate.ddl-auto=update  # Set to 'update' or 'create' depending on your needs
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true
```

### 2. **Replace Placeholders**
- `<RDS-endpoint>`: Replace this with the actual endpoint of your RDS MySQL instance.
- `<database-name>`: Replace with the name of your database in RDS (e.g., `product_db`).
- `<your-username>`: Replace with the RDS database username.
- `<your-password>`: Replace with the RDS database password.

## Build and Deploy Spring Boot Application

### 1. **Build the JAR File**

Build your Spring Boot application into a JAR file using Maven or Gradle.

**Using Maven:**

```bash
mvn clean install
```

**Using Gradle:**

```bash
gradle build
```

### 2. **Upload the JAR File to EC2**

Once the JAR file is built, upload it to your EC2 instance using `scp` or any file transfer method.

```bash
scp target/your-app.jar ec2-user@<your-ec2-ip>:/home/ec2-user/
```

### 3. **Run the Application on EC2**

SSH into your EC2 instance and run the Spring Boot application:

```bash
ssh -i /path/to/your-key.pem ec2-user@<your-ec2-ip>
java -jar your-app.jar
```

Make sure the security group associated with your EC2 instance allows inbound traffic on port `8080`.

### 4. **Test the Endpoints**

- **POST /store-products**: Send a JSON payload to store products in the database.
- **GET /list-products**: Retrieve a list of all products stored in the database.

## Conclusion

This project demonstrates how to configure a Spring Boot web application with an RDS MySQL database on AWS and deploy it to an EC2 instance. The application interacts with the database to store and retrieve product data through RESTful API endpoints.
### Key Updates:
- **EC2 Initialization**: Steps to install Java and Docker on EC2 are included.
- **MySQL Database Setup**: The Docker approach to creating a MySQL database in RDS is explained.
- **Terraform**: Terraform provisions the necessary AWS infrastructure, but the JAR file and database creation are done only after EC2 and RDS are available.

Let me know if you'd like further changes or additions!
