import express from "express"
import Customer from "../models/customer.js"

const router = express.Router()

router.post("/", async (req, res) => {
  try {
    const {
      phone,          // customer identify karne ke liye
      date,
      quantity,
      fatContent,
      pricePerLiter,
      shift,
      notes
    } = req.body

    // 1️⃣ find customer
    const customer = await Customer.findOne({ phone })
    if (!customer) {
      return res.status(404).json({ message: "Customer not found" })
    }

    const entryDate = new Date(date)
    const year = entryDate.getFullYear()
    const month = entryDate.getMonth() + 1

    const price =
      pricePerLiter || customer.milkSettings.defaultPricePerLiter

    const totalAmount = quantity * price

    // 2️⃣ find year
    let yearData = customer.milkRecords.years.find(y => y.year === year)

    if (!yearData) {
      yearData = {
        year,
        totalQuantity: 0,
        totalAmount: 0,
        months: []
      }
      customer.milkRecords.years.push(yearData)
    }

    // 3️⃣ find month
    let monthData = yearData.months.find(m => m.month === month)

    if (!monthData) {
      monthData = {
        year,
        month,
        totalQuantity: 0,
        totalAmount: 0,
        averageFatContent: 0,
        daysCount: 0,
        entries: []
      }
      yearData.months.push(monthData)
    }

    // 4️⃣ push milk entry
    monthData.entries.push({
      date: entryDate,
      quantity,
      fatContent,
      pricePerLiter: price,
      totalAmount,
      shift,
      notes
    })

    // 5️⃣ update month stats
    monthData.totalQuantity += quantity
    monthData.totalAmount += totalAmount
    monthData.daysCount += 1

    if (fatContent) {
      monthData.averageFatContent =
        (monthData.averageFatContent * (monthData.daysCount - 1) + fatContent) /
        monthData.daysCount
    }

    // 6️⃣ update year stats
    yearData.totalQuantity += quantity
    yearData.totalAmount += totalAmount
    yearData.averageMonthlyQuantity =
      yearData.totalQuantity / yearData.months.length

    // 7️⃣ update current month snapshot
    customer.milkRecords.currentMonthTotal = monthData.totalQuantity
    customer.milkRecords.currentMonthAmount = monthData.totalAmount
    customer.milkRecords.lastUpdated = new Date()

    await customer.save()

    res.status(201).json({
      message: "Milk entry added successfully",
      monthSummary: monthData
    })
  } catch (err) {
    res.status(500).json({ message: err.message })
  }
})

export default router
