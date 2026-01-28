import mongoose from "mongoose"

const milkEntrySchema = new mongoose.Schema({
  date: {
    type: Date,
    required: true
  },
  quantity: {
    type: Number,
    required: true,
    min: 0
  },
  fatContent: {
    type: Number,
    min: 0,
    max: 10
  },
  pricePerLiter: {
    type: Number,
    min: 0
  },
  totalAmount: {
    type: Number,
    min: 0
  },
  shift: {
    type: String,
    enum: ["morning", "evening", "full-day"],
    default: "full-day"
  },
  notes: String,
  verified: {
    type: Boolean,
    default: false
  }
}, { _id: true });

const monthlyMilkSummarySchema = new mongoose.Schema({
  year: {
    type: Number,
    required: true
  },
  month: {
    type: Number,
    required: true,
    min: 1,
    max: 12
  },
  totalQuantity: {
    type: Number,
    default: 0
  },
  totalAmount: {
    type: Number,
    default: 0
  },
  averageFatContent: {
    type: Number,
    default: 0
  },
  daysCount: {
    type: Number,
    default: 0
  },
  entries: [milkEntrySchema]
});

const yearlyMilkSummarySchema = new mongoose.Schema({
  year: {
    type: Number,
    required: true
  },
  totalQuantity: {
    type: Number,
    default: 0
  },
  totalAmount: {
    type: Number,
    default: 0
  },
  averageMonthlyQuantity: {
    type: Number,
    default: 0
  },
  months: [monthlyMilkSummarySchema]
});

const customerSchema = new mongoose.Schema(
  {
    // Basic Info
    name: {
      type: String,
      trim: true
    },

    phone: {
      type: String,
      required: true,
      unique: true
    },

    // OTP Auth
    otp: String,
    otpExpiry: Date,

    // Profile
    avatar: String,

    gender: {
      type: String,
      enum: ["male", "female", "other"]
    },

    dob: Date,

    // Address
    address: {
      street: String,
      city: String,
      state: String,
      pincode: String,
      country: {
        type: String,
        default: "India"
      }
    },

    // Milk Records
    milkRecords: {
      currentYear: {
        type: Number,
        default: new Date().getFullYear()
      },
      years: [yearlyMilkSummarySchema],
      currentMonthTotal: {
        type: Number,
        default: 0
      },
      currentMonthAmount: {
        type: Number,
        default: 0
      },
      lastUpdated: Date
    },

    // Milk Settings
    milkSettings: {
      defaultPricePerLiter: {
        type: Number,
        default: 75,
      },
      defaultShift: {
        type: String,
        enum: ["morning", "evening", "full-day"],
        default: "full-day"
      },
      measurementUnit: {
        type: String,
        enum: ["liter", "kg"],
        default: "liter"
      }
    }
  },
  {
    timestamps: true
  }
);

const Customer = mongoose.model("Customer", customerSchema)
export default Customer