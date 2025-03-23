# Melo - Your AI Friend for Mental Well-Being

Melo is a mental well-being app that tracks emotions based on audio conversations. It integrates with our proprietary emotion detection model, *Colon*, to analyze speech, detect emotions, and generate personalized AI-driven responses. Melo acts as your AI companion, offering emotional support and insights into your mental health trends.

## Features

- *Emotion Detection*: Analyzes speech patterns to understand emotions.
- *AI Conversations*: Engages in meaningful conversations based on detected emotions.
- *Emotion Insights*: Provides a pie chart visualization of past emotions to track emotional well-being over time.

## Testing the App

You can test the app through this Drive link:
https://drive.google.com/drive/folders/1wQ8tAipVWCv98bwTAIuMDelGI6KA2xz2?usp=sharing

## Tech Stack

- *Frontend*: Flutter
- *Backend*: FastAPI (or any API service used)
- *Emotion Detection Model*: Colon (our very own ML model)

## Contributing

We welcome contributions! If you’d like to improve Melo, feel free to open an issue or submit a pull request.

## License

Melo is open-source. Feel free to use and modify it as needed.

---

Built with ❤ to support mental well-being.


# Emotion Detection Model

## 📦 *Project Overview*
We have created an Emotion Detector Machine Learning Model and uploaded it to *Hugging Face* .
This project uses *FastAPI* to deploy a voice emotion detection model. The model is stored in a pickle file (best_rf_model.pkl) and is downloaded from *Hugging Face* if not found locally. It extracts audio features using *librosa* and predicts the mood.

## 🚀 *Setup Instructions*

###1. *Clone the Repository*
https://github.com/Saksham886/Team_semicolon/tree/main/Model_API

### 2. *Create a Virtual Environment*
bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate


### 3. *Install Requirements*
Ensure you have a requirements.txt file with the following (or similar) dependencies:

fastapi
uvicorn
librosa
numpy
joblib
requests

bash
pip install -r requirements.txt


## 📤 *Running the API locally*

### 4. *Run Locally*
bash
uvicorn main:app --host 0.0.0.0 --port 8000


## 🔍 *Using the API locally*

### *Endpoint:*

POST /predict


### *Request Format:*
- Upload a .wav audio file.

### *Response Format:*
json
{
  "mood": "Predicted mood label"
}


## ⚠ *Common Issues*

- *Model Not Found:*
  - Ensure the correct Hugging Face username and repository.
- *Port Issues:*
  - Use os.environ.get("PORT", 8000) for dynamic port allocation.
- *Librosa Load Error:*
  - Verify audio file format and sampling rate.

# Emotion Detector API (Colon)

## Overview
The *Colon Emotion Detector Public API* is a FastAPI-based service that processes .wav audio files and returns an emotion prediction. It accepts *POST requests* with multipart/form-data.

## API Endpoint

POST https://colonemotion-production.up.railway.app/predict


## Request Format
- *Method*: POST
- *Content-Type*: multipart/form-data
- *Parameter*: file (The .wav file to be uploaded)

## Example Request (cURL)
sh
curl -X POST "https://colonemotion-production.up.railway.app/predict" \
     -H "Content-Type: multipart/form-data" \
     -F "file=@path/to/audio.wav"


## Example Request (Dart/Flutter using http package)
dart
import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> sendAudioToAPI(File audioFile) async {
  var request = http.MultipartRequest(
    'POST',
    Uri.parse('https://colonemotion-production.up.railway.app/predict'),
  );

  request.files.add(
    await http.MultipartFile.fromPath(
      'file', // This should match the FastAPI parameter name
      audioFile.path,
    ),
  );

  try {
    var response = await request.send();
    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      print("Predicted Emotion: $responseData");
    } else {
      print("Error: ${response.statusCode}");
    }
  } catch (e) {
    print("Exception: $e");
  }
}


## Example Response
json
{
  "mood": "happy"
}


## Error Handling
- 400 Bad Request: If no file is uploaded.
- 415 Unsupported Media Type: If the uploaded file is not in .wav format.
- 500 Internal Server Error: If an unexpected error occurs.

## Notes
- Ensure the uploaded file is in **.wav format**.
- The API processes audio and returns the detected emotion in JSON format.
- Use the **correct form-data key (file)** when sending the request.

## Contributors
Developed by the *SemiColon Team*.

Warning ⚠

This APIs and Model are hosted on a free platform, so there may be occasional downtime or slow responses. If you experience issues, please try again later.

## 📞 *Contact*
For any questions, feel free to reach out at *utkarshgsuv@gmail.com*.
