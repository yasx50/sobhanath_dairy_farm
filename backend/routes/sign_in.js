import express from "express"
import Customer from "../models/customer.js"

const router = express.Router()

router.post("/", async (req, res) => {
  try {
    const { name, phone } = req.body

    if ( !phone) {
      return res.status(400).json({ message: "Name and phone are required" })
    }

    const customer = await Customer.findOne({  phone })

    if (!customer) {
      return res.status(404).json({ message: "Customer not found" })
    }

    res.status(200).json({
      message: "Login successful",
      customer
    })
  } catch (error) {
    console.error("Error during login:", error)
    res.status(500).json({ message: "Error during login" })
  }
})

export default router
