from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List, Literal
from datetime import datetime
import uuid


# ---------------- ENUMS (STRICT & SAFE) ----------------
PlanType = Literal["FREE", "BASIC", "PREMIUM"]
PaymentStatus = Literal["TRIAL", "ACTIVE", "EXPIRED", "CANCELLED"]
AuthProvider = Literal["GOOGLE", "APPLE"]
DeviceType = Literal["ANDROID", "IOS", "WEB"]


# ---------------- OWNER MODEL ----------------
class Owner(BaseModel):
    # ---------------- Core Identity ----------------
    owner_id: str = Field(default_factory=lambda: uuid.uuid4().hex)
    name: str
    email: EmailStr
    phone: str

    # ---------------- Authentication ----------------
    auth_provider: AuthProvider
    is_active: bool = True
    is_verified: bool = True

    # ---------------- Subscription ----------------
    plan: PlanType = "FREE"
    payment_status: PaymentStatus = "TRIAL"

    plan_start_date: datetime = Field(default_factory=datetime.utcnow)
    plan_expiry_date: Optional[datetime] = None
    trial_days_left: int = 7

    # ---------------- Plan Limits (SaaS Core Logic) ----------------
    max_customers_allowed: int = 10     # FREE default
   

    # ---------------- Business Mapping ----------------
    dairies: List[str] = []  # list of dairy_ids

    # ---------------- Usage Tracking ----------------
    customers_count: int = 0
    

    # ---------------- Metadata ----------------
    created_at: datetime = Field(default_factory=datetime.utcnow)
    last_login: Optional[datetime] = None
    device_type: Optional[DeviceType] = None

    # ---------------- Utility ----------------
    def apply_plan_limits(self):
        """Call this whenever plan changes"""
        if self.plan == "FREE":
            self.max_customers_allowed = 10
            

        elif self.plan == "BASIC":
            self.max_customers_allowed = 50
            
        elif self.plan == "PREMIUM":
            self.max_customers_allowed = 100
            