'use strict';

/**
 * Cedar Ridge National Park — knowledge base content for the Trailhead
 * assistant. Plain Q&A pairs. All ASCII (the KB description and article
 * bodies reject non-ASCII such as the em-dash). Demo data for a fictional park.
 */

const KNOWLEDGE_BASE = {
  name: 'cedarridge-faq',
  type: 'articles',
  description: 'Cedar Ridge National Park visitor FAQ - hours, permits, trails, wildlife safety.',
  mainLanguageCode: 'en-US',
};

const ARTICLES = [
  {
    question: 'What are the park hours?',
    answer:
      'Cedar Ridge is open year-round, 24 hours a day. The main visitor center is open from 8 AM to 5 PM daily.',
  },
  {
    question: 'When is the best time to visit?',
    answer:
      'Late spring through early fall has the mildest weather. Trails at higher elevations may have snow into June.',
  },
  {
    question: 'Do I need a permit to hike?',
    answer:
      'Day hikes do not require a permit. Overnight backcountry trips require a free wilderness permit, available at the visitor center or online.',
  },
  {
    question: 'How much is the entrance fee?',
    answer: 'A vehicle pass is $30 and is valid for 7 days. An annual pass is $55.',
  },
  {
    question: 'Do I need a permit to camp?',
    answer:
      'Yes. Backcountry camping requires a wilderness permit, and developed campgrounds require a reservation.',
  },
  {
    question: 'What is a good beginner trail?',
    answer:
      'The Meadow Loop is a flat 2-mile trail near the visitor center, great for beginners and families.',
  },
  {
    question: 'What is the hardest trail?',
    answer:
      'Summit Ridge is a strenuous 11-mile round trip with 4,000 feet of elevation gain. Start early and carry plenty of water.',
  },
  {
    question: 'Are dogs allowed on trails?',
    answer:
      'Leashed dogs are welcome on the Meadow Loop and Riverside Trail, but not on backcountry or summit trails to protect wildlife.',
  },
  {
    question: 'What should I do if I see a bear?',
    answer:
      'Stay calm, do not run, back away slowly, and make yourself look large. Never feed wildlife, and store food in provided bear lockers.',
  },
  {
    question: 'Is there cell service in the park?',
    answer:
      'Cell service is limited and unavailable in most backcountry areas. Download maps before you go and tell someone your route.',
  },
  {
    question: 'Are any trails closed?',
    answer: 'Trail closures change with conditions. I can connect you with a ranger for current closure information.',
  },
];

module.exports = { KNOWLEDGE_BASE, ARTICLES };
