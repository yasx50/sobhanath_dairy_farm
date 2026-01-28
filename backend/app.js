import express from "express"
import cors from "cors"
import milk_entry from "./routes/milk_entry.js"

const app = express()

app.use(cors())
app.use(express.json())
app.use(express.urlencoded({ extended: true }))
app.use("/milk-entry", milk_entry)

// auth
import sign_up from "./routes/sign_up.js"
app.use("/sign-up", sign_up)
import sign_in from "./routes/sign_in.js"
app.use("/login", sign_in)



app.get("/", (req, res) => {
  res.send("OTP Auth Backend Running 🚀")
})

export default app
