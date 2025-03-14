```markdown
# AWS EC2 VPC Product Management Web Application

This repository contains a Spring Boot web application deployed on AWS EC2 behind a Virtual Private Cloud (VPC). The app provides two main endpoints:

- `/store-products` - stores product data in an AWS RDS database
- `/list-products` - retrieves and displays stored products from the database

The AWS infrastructure (EC2, RDS, VPC) is provisioned using Terraform.

## Features
- Deployed on AWS EC2 instance within a Virtual Private Cloud (VPC)
- Stores product data in an AWS RDS database
- Two main API endpoints:
  - `POST /store-products` - Accepts JSON data to store products in the database
  - `GET /list-products` - Retrieves the list of all stored products
- Implements basic REST API principles using Spring Boot
- Demonstrates secure architecture using AWS VPC and RDS integration
- Terraform scripts to automate AWS resource provisioning

## Prerequisites

Before running the application, make sure you have the following:

- **Java 17 or higher** installed
- **Maven** or **Gradle** for building the application
- **Terraform** installed
- **AWS Account** for EC2 and RDS configuration
- **Postman** or similar tool for testing API requests

## AWS Setup Using Terraform

### 1. Clone the Repository

First, clone the repository to your local machine:

```bash
git clone https://github.com/<your-username>/aws-ec2-vpc-product-management.git
cd aws-ec2-vpc-product-management
```

### 2. Initialize Terraform

Navigate to the `terraform/` directory in your project folder. Ensure that your AWS credentials are properly configured, either by using the AWS CLI or by setting the environment variables `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`.

```bash
cd terraform
terraform init
```

### 3. Configure Terraform Variables

Make sure you have a valid `terraform.tfvars` file with your AWS credentials and region configuration:

```hcl
aws_access_key_id = "<Your_AWS_Access_Key>"
aws_secret_access_key = "<Your_AWS_Secret_Access_Key>"
aws_region = "us-east-1"
```

### 4. Provision the AWS Infrastructure

Run the following Terraform commands to apply the infrastructure configuration:

```bash
terraform plan
terraform apply
```

Terraform will ask for your confirmation before provisioning the resources. Once you approve, it will create the VPC, EC2 instance, and RDS database.

### 5. Retrieve EC2 Public IP

After the Terraform apply is successful, note the public IP of your EC2 instance, which will be used to access the Spring Boot application.

```bash
terraform output ec2_public_ip
```

### 6. Deploy the Web Application

After provisioning the infrastructure, deploy your Spring Boot application on the EC2 instance. You can either SSH into the EC2 instance or use a tool like AWS Systems Manager to deploy the application.

To SSH into the EC2 instance (replace `<public-ip>` with the actual public IP of the instance):

```bash
ssh -i "your-ec2-key.pem" ec2-user@<public-ip>
```

Once logged in, clone your repository on the EC2 instance:

```bash
git clone https://github.com/<your-username>/aws-ec2-vpc-product-management.git
cd aws-ec2-vpc-product-management
```

Build and run the Spring Boot application:

```bash
mvn clean install
mvn spring-boot:run
```

The application should now be running on the public IP of your EC2 instance.

## API Endpoints

### 1. `POST /store-products`
- **Request Body:**
  ```json
  {
    "products": [
      {
        "name": "Product1",
        "price": "100",
        "availability": true
      },
      {
        "name": "Product2",
        "price": "200",
        "availability": false
      }
    ]
  }
  ```

- **Response:**
  ```json
  {
    "message": "Success."
  }
  ```

### 2. `GET /list-products`
- **Response:**
  ```json
  {
    "products": [
      {
        "name": "Product1",
        "price": "100",
        "availability": true
      },
      {
        "name": "Product2",
        "price": "200",
        "availability": false
      }
    ]
  }
  ```


## Conclusion

This project demonstrates integrating AWS services such as EC2, VPC, and RDS for deploying a secure web application. It also shows how to interact with RDS databases from a Spring Boot application. The infrastructure is provisioned using Terraform, which automates the creation of VPC, EC2, and RDS resources. 
