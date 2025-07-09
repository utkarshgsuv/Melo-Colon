
# 🎧 Melo — Your AI Friend for Mental Well-Being

Melo is an AI-powered mental well-being app designed to support your emotional health. It tracks emotions based on voice conversations, integrates with our proprietary emotion detection model (Colon), and engages in personalized, supportive dialogues. Melo acts as your personal AI companion, offering real-time emotional support and insights into your mental health trends.

---

## 🌟 Features

- **🎙️ Emotion Detection:** Analyzes speech patterns to understand user emotions using advanced audio feature extraction.
- **💬 AI Conversations:** Engages in meaningful, context-aware conversations based on detected emotions to calm and motivate users.
- **📊 Emotion Insights:** Visualizes emotional trends with a pie chart dashboard, helping users track emotional well-being over time.

---

## 🚀 Try the App

- [Google Drive Demo Link](https://drive.google.com/drive/folders/1wQ8tAipVWCv98bwTAIuMDelGI6KA2xz2?usp=sharing)

---

## 🛠️ Tech Stack

- **Frontend:** Flutter (cross-platform mobile and web)
- **Backend:** FastAPI (Python)
- **ML Model:** Colon (proprietary emotion detection model)
- **Audio Processing:** librosa
- **Model Hosting:** Hugging Face
- **Deployment:** Uvicorn, Railway

---

## 🧠 Emotion Detection Model — Colon

### 📦 Overview

Colon is a custom machine learning model that detects emotions from voice recordings. It uses audio feature extraction (MFCC, spectral features, etc.) via `librosa`, and predicts mood using a Random Forest classifier. The model is deployed using FastAPI and hosted on Hugging Face.

---

### 🚀 Setup Instructions

1️⃣ **Clone the Repository**

```bash
git clone https://github.com/utkarshgsuv/Melo-Colon/tree/main/Model_API
cd Model_API
```

2️⃣ **Create Virtual Environment**

```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3️⃣ **Install Requirements**

```bash
pip install -r requirements.txt
```

4️⃣ **Run the API Locally**

```bash
uvicorn main:app --host 0.0.0.0 --port 8000
```

---

### 🔍 API Usage

**Endpoint:** `POST /predict`

- **Request:** Upload a `.wav` audio file (`multipart/form-data` with parameter name: `file`).
- **Response:**

```json
{
  "mood": "happy"
}
```

---

#### 💡 Example cURL Request

```bash
curl -X POST "https://colonemotion-production.up.railway.app/predict" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@path/to/audio.wav"
```

---

## ⚠️ Notes & Common Issues

- Ensure the audio file is in `.wav` format.
- Use correct form-data key (`file`) when uploading.
- API hosted on free platforms (may experience occasional downtime or slow responses).

---

## 🤝 Contributing

We welcome contributions! Feel free to open issues or submit pull requests to improve Melo.

---

## 📄 License

Melo is open-source. Feel free to use and modify it as needed.

---

## 💌 Contact

For questions or feedback, please reach out at **utkarshgsuv@gmail.com**.

---

> Built with ❤️ to support mental well-being.
