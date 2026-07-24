import OpenAI from "npm:openai@^4";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const apiKey = Deno.env.get("OPENAI_API_KEY");

if (!apiKey) {
  throw new Error("OPENAI_API_KEY is not configured.");
}

const openai = new OpenAI({
  apiKey,
});

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      status: 200,
      headers: corsHeaders,
    });
  }

  if (req.method !== "POST") {
    return new Response(
      JSON.stringify({
        error: "Method not allowed. Use POST.",
      }),
      {
        status: 405,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
        },
      },
    );
  }

  try {
    const body = await req.json();

    const gradeLevel = body.gradeLevel;
    const topic = body.topic;
    const dolchWords = body.dolchWords;

    if (
      typeof gradeLevel !== "string" ||
      typeof topic !== "string" ||
      !Array.isArray(dolchWords) ||
      dolchWords.length === 0
    ) {
      return new Response(
        JSON.stringify({
          error:
            "gradeLevel, topic, and at least one Dolch word are required.",
        }),
        {
          status: 400,
          headers: {
            ...corsHeaders,
            "Content-Type": "application/json",
          },
        },
      );
    }

const prompt = `
You are an elementary reading teacher.

Your job is to create a reading practice story for a child.

Reading Level:
${gradeLevel}

Story Topic:
${topic}

Required Dolch Sight Words:
${dolchWords.join(", ")}

Instructions:

1. Include EVERY Dolch sight word exactly as written.
2. Use each sight word at least once.
3. Do not skip any of the words.
4. Make the story between 150 and 200 words.
5. Use short, easy-to-read sentences.
6. Keep the vocabulary appropriate for the reading level (${gradeLevel}).
7. Make the story fun, positive, and engaging.
8. Keep the story focused on the topic "${topic}".
9. Do not number anything.
10. Do not include a title.
11. Return ONLY the story text.
`;
    console.log("Calling OpenAI...");

    const response = await openai.responses.create({
      model: "gpt-5-mini",
      input: prompt,
    });

    const story = response.output_text?.trim();

    if (!story) {
      throw new Error("OpenAI returned an empty story.");
    }

    return new Response(
      JSON.stringify({
        story,
      }),
      {
        status: 200,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
        },
      },
    );
  } catch (err) {
    console.error("Generate Story Error:", err);

    return new Response(
      JSON.stringify({
        error: err instanceof Error ? err.message : String(err),
      }),
      {
        status: 500,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
        },
      },
    );
  }
});