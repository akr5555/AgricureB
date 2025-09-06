[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/template/AgriCure-Backend)

# AgriCure Backend - One-Click Railway Deployment

## 🚀 Deploy Now

Click the "Deploy on Railway" button above for instant deployment!

Or manually deploy:

1. **Fork this repository**
2. **Go to [Railway](https://railway.app)**
3. **Click "Deploy from GitHub"**
4. **Select this repository**
5. **Your API will be live in 2-3 minutes!**

## 🔗 After Deployment

You'll get a public URL like: `https://agricure-backend-production.up.railway.app`

### Test Your Deployment:
- Health Check: `https://your-url/health`
- API Docs: `https://your-url/docs`
- Prediction: `https://your-url/predict`

### Use in Frontend:
```javascript
const API_URL = "https://your-railway-url";

// Example API call
fetch(`${API_URL}/predict`, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    Temperature: 26.0,
    Humidity: 80.0,
    Moisture: 35.0,
    Soil_Type: "Loamy",
    Crop_Type: "rice",
    Nitrogen: 85.0,
    Potassium: 45.0,
    Phosphorous: 35.0
  })
})
```

## 💰 Cost
- **FREE** up to 500 hours/month
- **$5/month** for unlimited usage
- No credit card required for free tier

## 🛠️ Manual Deployment Script
If you prefer command line:
```powershell
# Windows
.\deploy-public.ps1

# Select option 1 (Railway)
```

**Happy Deploying! 🎉**
