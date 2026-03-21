const fetch = require('node-fetch');

async function testApi() {
    try {
        console.log("1. Authenticating Professeur...");
        const loginRes = await fetch('http://localhost:8000/api/professeur/login', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            },
            body: JSON.stringify({
                email: 'marsben200@gmail.com',
                password: 'MITCH1059'
            })
        });

        const loginData = await loginRes.json();
        if (!loginData.success) {
            console.error("Login failed:", loginData);
            return;
        }

        const token = loginData.token;
        console.log("Login successful! Token acquired.");

        const endpoints = [
            '/api/professeurs/espace/dashboard',
            '/api/professeurs/classes',
            '/api/professeurs/espace/emploi-du-temps',
            '/api/notes',
            '/api/cahier-texte'
        ];

        for (const endpoint of endpoints) {
            console.log(`\n--- GET ${endpoint} ---`);
            const res = await fetch(`http://localhost:8000${endpoint}`, {
                headers: {
                    'Authorization': `Bearer ${token}`,
                    'Accept': 'application/json'
                }
            });

            const status = res.status;
            console.log(`Status: ${status}`);

            if (status === 500) {
                console.error("500 ERROR DETECTED:");
                const text = await res.text();
                try {
                    const json = JSON.parse(text);
                    console.error(json.message);
                    console.error(json.exception);
                } catch {
                    console.error(text.substring(0, 500) + "...");
                }
            } else {
                const data = await res.json();
                console.log("SUCCESS. Keys:", Object.keys(data));
            }
        }
    } catch (e) {
        console.error("Test Script Error:", e);
    }
}

testApi();
