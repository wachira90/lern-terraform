### **How to Install and Use Terraform (Step-by-Step Guide)**

Terraform is an Infrastructure as Code (IaC) tool that allows you to define and provision infrastructure using a high-level configuration language.

---

## **Step 1: Install Terraform**
### **1.1 Install Terraform on Windows**
#### **Using Chocolatey (Recommended)**
1. Open **PowerShell** as Administrator.
2. Run:
   ```powershell
   choco install terraform
   ```
3. Verify the installation:
   ```powershell
   terraform -version
   ```

#### **Using Manual Installation**
1. Download the Terraform binary from the official website:  
   👉 [https://developer.hashicorp.com/terraform/downloads](https://developer.hashicorp.com/terraform/downloads)
2. Extract the `.zip` file.
3. Move the extracted folder to `C:\terraform` (or any location).
4. Add Terraform to **System Environment Variables**:
   - Open **Control Panel** → **System** → **Advanced system settings**.
   - Click **Environment Variables**.
   - Under **System variables**, find `Path`, click **Edit**.
   - Click **New** and add `C:\terraform`.
   - Click **OK** and restart your terminal.
5. Verify installation:
   ```powershell
   terraform -version
   ```

---

### **1.2 Install Terraform on Linux & macOS**
#### **Using Homebrew (macOS)**
1. Open the terminal and run:
   ```sh
   brew install terraform
   ```
2. Verify installation:
   ```sh
   terraform -version
   ```

#### **Using Manual Installation (Linux/macOS)**
1. Download Terraform:
   ```sh
   curl -fsSL -o terraform.zip "https://releases.hashicorp.com/terraform/$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r '.current_version')/terraform_$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r '.current_version')_$(uname -s | tr '[:upper:]' '[:lower:]')_amd64.zip"
   ```
2. Unzip the file:
   ```sh
   unzip terraform.zip
   ```
3. Move Terraform binary to `/usr/local/bin`:
   ```sh
   sudo mv terraform /usr/local/bin/
   ```
4. Verify installation:
   ```sh
   terraform -version
   ```

---

## **Step 2: Set Up Terraform Project**
### **2.1 Create a Working Directory**
```sh
mkdir terraform_project
cd terraform_project
```

### **2.2 Write a Terraform Configuration File**
Create a file named `main.tf`:
```sh
touch main.tf
```
Add the following content to `main.tf`:
```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
}
```

### **2.3 Initialize Terraform**
Run:
```sh
terraform init
```
This downloads the required provider plugins.

### **2.4 Plan the Execution**
```sh
terraform plan
```
This shows what Terraform will create.

### **2.5 Apply the Configuration**
```sh
terraform apply
```
Type **"yes"** when prompted.

### **2.6 Verify Resources**
Check in AWS Console or run:
```sh
aws ec2 describe-instances
```

### **2.7 Destroy the Resources**
To delete everything:
```sh
terraform destroy
```

---

## **Step 3: Additional Terraform Commands**
- **Format code**:  
  ```sh
  terraform fmt
  ```
- **Validate syntax**:  
  ```sh
  terraform validate
  ```
- **Show Terraform state**:  
  ```sh
  terraform show
  ```
- **List resources**:  
  ```sh
  terraform state list
  ```

---

## **That's it!** 🎉 Now you can use Terraform to manage your infrastructure! 🚀
