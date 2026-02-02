import express from "express";
import Customer from "../models/customer.js";

const router = express.Router();

// GET customer details by phone number
router.get("/:phoneNumber", async (req, res) => {
  try {
    const { phoneNumber } = req.params;

    if (!phoneNumber) {
      return res.status(400).json({ message: "Phone number is required" });
    }

    const customer = await Customer.findOne({ phone: phoneNumber });

    if (!customer) {
      return res.status(404).json({ message: "Customer not found" });
    }

    res.status(200).json({
      message: "Customer found",
      customer
    });
  } catch (error) {
    console.error("Error fetching customer:", error);
    res.status(500).json({ message: "Error fetching customer details" });
  }
});

export default router;