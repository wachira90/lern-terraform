# **Terraform workspace** 

ถูกออกแบบมาเพื่อช่วยให้คุณสามารถจัดการ **State (สถานะของ Infrastructure)** หลายๆ ชุด ภายใต้ **Configuration Code (โฟลเดอร์โค้ด) เดียวกัน** ได้อย่างเป็นอิสระต่อกัน

กรณีการใช้งานหลักๆ ของ Terraform workspace มีดังนี้:

## 1. การแยก Environment (Dev, UAT, Prod)

นี่คือกรณีการใช้งานที่พบบ่อยที่สุด คุณสามารถใช้โค้ด Terraform ชุดเดียวกันเป๊ะๆ เพื่อสร้าง Infrastructure สำหรับแต่ละ Environment ได้ โดยการสร้าง Workspace แยกกัน เช่น:

* `terraform workspace new dev`
* `terraform workspace new uat`
* `terraform workspace new prod`

ข้อดีคือเมื่อคุณรัน `terraform apply` ใน Workspace `dev` ตัว Terraform จะไปอัปเดตเฉพาะ State ไฟล์ของฝั่ง Dev โดยไม่กระทบกับ State ของฝั่ง Prod เลย

## 2. การสร้างตัวแปรแบบไดนามิกตาม Workspace

ภายในโค้ด Terraform คุณสามารถอ้างอิงชื่อ Workspace ปัจจุบันได้ผ่านตัวแปร `terraform.workspace` ซึ่งมักจะถูกนำมาใช้เพื่อตั้งชื่อ Resource หรือดึงค่าตัวแปร (Variables) ให้เหมาะสมกับ Environment นั้นๆ แบบอัตโนมัติ

> **ตัวอย่าง:** หากคุณกำหนดชื่อ S3 Bucket ในโค้ดว่า `my-app-data-${terraform.workspace}`
> * ถ้ารันใน Workspace `dev` จะได้ชื่อ `my-app-data-dev`
> * ถ้ารันใน Workspace `prod` จะได้ชื่อ `my-app-data-prod`
> 
> 

## 3. การทดสอบโค้ดแบบชั่วคราว (Testing / Isolation)

เมื่อคุณต้องการทดลองเขียนโค้ดเพื่อปรับเปลี่ยน Infrastructure แต่ไม่อยากให้เสี่ยงกระทบกับ State หลักที่ทีมงานกำลังใช้งานอยู่ คุณสามารถสร้าง Workspace ใหม่ขึ้นมาชั่วคราว (เช่น `terraform workspace new feature-test`) เพื่อรัน `terraform plan` หรือ `apply` ทดสอบดู เมื่อทดสอบเสร็จและมั่นใจแล้ว ค่อยกลับไปใช้ Workspace หลัก และลบ Workspace ชั่วคราวนี้ทิ้งไป

## 4. การจัดการ Multi-Tenant หรือ Multi-Region

หากคุณมีระบบที่ต้องทำซ้ำๆ กัน (Replica) เช่น มีลูกค้าหลายรายที่ใช้โครงสร้างระบบแบบเดียวกันเป๊ะ หรือต้องการ Deploy ระบบหน้าตาเหมือนกันไปยังหลาย Region ของ AWS (เช่น `us-east-1` และ `ap-southeast-1`) คุณสามารถสร้าง Workspace แยกตามชื่อลูกค้าหรือชื่อ Region ได้ เพื่อให้ใช้โค้ดชุดเดียวจัดการได้ทั้งหมด

---

### ข้อควรระวังในการใช้งาน (Best Practices)

แม้ Workspaces จะสะดวกมากในการจัดการ Environment ที่มีโครงสร้างคล้ายกัน แต่มีข้อจำกัดที่ควรทราบ:

* **หลีกเลี่ยงการใช้กับระบบที่ซับซ้อนต่างกัน:** หาก Environment ของคุณมีความแตกต่างกันมากๆ (เช่น Prod มี Resource ซับซ้อนกว่า Dev มาก หรือมีระบบ Network คนละแบบ) การใช้ Workspace เดียวกันร่วมกับเงื่อนไข (If-else/count) เยอะๆ จะทำให้โค้ดอ่านยากและบำรุงรักษายาก
* **ความเสี่ยงเรื่อง Blast Radius:** เนื่องจากใช้โค้ดชุดเดียวกัน การแก้โค้ดผิดพลาด 1 จุดอาจกระทบได้ทุก Environment หากลืมสลับ Workspace
* **คำแนะนำจาก HashiCorp:** สำหรับระบบขนาดใหญ่ระดับ Production ทางผู้สร้าง Terraform มักจะแนะนำให้ **แยกโฟลเดอร์ (Directory separation)** หรือแบ่ง Module ตาม Environment ไปเลย จะปลอดภัยกว่าการใช้ Workspace จัดการ Environment หลัก
