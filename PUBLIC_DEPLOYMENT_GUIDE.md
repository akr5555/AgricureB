# 🌐 PUBLIC DEPLOYMENT GUIDE - Get Your Backend Online in 5 Minutes

## 🚀 FASTEST METHOD: Railway (FREE)

Railway provides free hosting with a public URL that your frontend can use.

### Step 1: Run the Public Deployment Script
```powershell
cd backend
.\deploy-public.ps1
```

### Step 2: Choose Option 1 (Railway)
The script will:
1. Install Railway CLI
2. Open browser for login
3. Deploy your backend
4. Give you a public URL like: `https://your-app.railway.app`

### Step 3: Update Your Frontend
Use the Railway URL in your frontend to replace any localhost URLs:
```javascript
// Replace this:
const API_URL = "http://localhost:8000"

// With your Railway URL:
const API_URL = "https://your-app.railway.app"
```

---

## 🔧 ALTERNATIVE METHODS

### Option A: Manual Railway Deployment
```bash
# Install Railway CLI
npm install -g @railway/cli

# Login (opens browser)
railway login

# Initialize project
railway init

# Deploy
railway up

# Get your URL
railway domain
```

### Option B: Render (Free, requires GitHub)
1. Push your code to GitHub
2. Go to https://render.com
3. Connect GitHub repository
4. Use Docker environment
5. Deploy

### Option C: Heroku (Paid but reliable)
```bash
# Install Heroku CLI, then:
heroku login
heroku create your-app-name
heroku container:login
heroku container:push web
heroku container:release web
```

---

## 🎯 QUICK TEST

Once deployed, test your public API:

```bash
# Test health endpoint
curl https://your-app.railway.app/health

# Test prediction
curl -X POST "https://your-app.railway.app/predict" \
  -H "Content-Type: application/json" \
  -d '{
    "Temperature": 26.0,
    "Humidity": 80.0,
    "Moisture": 35.0,
    "Soil_Type": "Loamy",
    "Crop_Type": "rice",
    "Nitrogen": 85.0,
    "Potassium": 45.0,
    "Phosphorous": 35.0
  }'
```

---

## 🔗 CONNECT FRONTEND

After deployment, you'll get a public URL. Update your frontend configuration:

### React/Vue/Angular Frontend:
```javascript
// In your API configuration file
export const API_BASE_URL = "https://your-app.railway.app";

// Use in your requests
fetch(`${API_BASE_URL}/predict`, {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify(data)
})
```

### Environment Variables (.env):
```
VITE_API_URL=https://your-app.railway.app
REACT_APP_API_URL=https://your-app.railway.app
```

---

## 🔒 CORS CONFIGURATION

Your backend is already configured to accept requests from any domain:
```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

---

## 📞 SUPPORT

If you encounter issues:
1. Check the logs in Railway dashboard
2. Ensure all model files are included in the deployment
3. Verify the health endpoint responds: `https://your-url/health`

**Your backend will be publicly accessible and ready for your frontend! 🎉**
