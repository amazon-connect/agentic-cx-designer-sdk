'use strict';

/**
 * AutoCare Auto Repair — knowledge base content for the AutoCare Voice Assistant.
 *
 * Plain Q&A pairs. The deploy script creates a knowledge base and reconciles
 * one article per entry (create-or-update, keyed on the question text). Prices
 * and hours are illustrative demo values — edit freely.
 */

const KNOWLEDGE_BASE = {
  name: 'autocare-faq',
  type: 'articles',
  description: 'AutoCare Auto Repair FAQ - hours, pricing, and services.',
  mainLanguageCode: 'en-US',
};

const ARTICLES = [
  {
    question: 'What are your hours?',
    answer:
      "We're open Monday through Friday from 8 AM to 6 PM, Saturday from 9 AM to 4 PM, and we're closed on Sundays.",
  },
  {
    question: 'How much does a car cleaning cost?',
    answer:
      'A standard car cleaning and detailing is $100. If you are a returning customer, it is $80.',
  },
  {
    question: 'Do returning customers get a discount?',
    answer: 'Yes - returning customers pay $80 for a cleaning, instead of the standard $100.',
  },
  {
    question: 'How much is an oil change?',
    answer: 'A standard oil change is $55.',
  },
  {
    question: 'How much does a tire rotation cost?',
    answer: 'A tire rotation is $45, and it is free when bundled with an oil change.',
  },
  {
    question: 'How much is a brake inspection?',
    answer: 'A brake inspection is $35, and it is waived if we perform the brake repair.',
  },
  {
    question: 'What services do you offer?',
    answer:
      'We offer oil changes, tire rotations, brake service, car cleaning and detailing, and general repair and diagnostics.',
  },
  {
    question: 'Where are you located?',
    answer:
      "We're at 123 Main Street. For directions or to book an appointment, I can connect you with a service advisor.",
  },
];

module.exports = { KNOWLEDGE_BASE, ARTICLES };
