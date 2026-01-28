import express from "express"
import Customer from "../models/customer.js"

const router = express.Router()

router.post("/", async (req, res) => {
  try {
    const { name, phone, address } = req.body

    if (!phone) {
      return res.status(400).json({ message: "Phone is required" })
    }

    const existingCustomer = await Customer.findOne({ phone })
    if (existingCustomer) {
      return res
        .status(400)
        .json({ message: "Customer with this phone number already exists" })
    }

    const customer = await Customer.create({
      name,
      phone,
      address
    })

    res.status(201).json({
      message: "Customer created successfully",
      customer
    })
  } catch (error) {
    console.error("Error during sign up:", error)
    res.status(500).json({ message: "Error during sign up" })
  }
})

export default router
