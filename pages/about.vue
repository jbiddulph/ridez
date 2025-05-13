<template>
  <div class="min-h-screen bg-gray-100 dark:bg-gray-900 py-12">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6">
        <h1 class="text-3xl font-bold mb-6 text-gray-900 dark:text-white">About Ridez</h1>
        <p class="text-gray-600 mb-4 text-gray-900 dark:text-white">
          Ridez is your personal travel companion that helps you track and manage your journeys.
          Whether you're walking, cycling, or driving, Ridez makes it easy to record your trips
          and keep track of your expenses.
        </p>
        <p class="text-gray-600 mb-4 text-gray-900 dark:text-white">
          Our mission is to make travel tracking simple and efficient, helping you understand
          your travel patterns and manage your transportation costs.
        </p>
      </div>
    </div>
    <!-- FAQ Section -->
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 mt-10">
      <div class="bg-gray-100 dark:bg-gray-800 rounded-lg shadow-lg p-6">
        <h2 class="text-2xl font-bold mb-6 text-gray-900 dark:text-white">Frequently Asked Questions</h2>
        <div class="space-y-6">
          <div v-for="(faq, index) in faqs" :key="index" class="border-b pb-4">
            <button 
              @click="toggleFaq(index)"
              class="w-full text-left flex justify-between items-center focus:outline-none"
            >
              <h3 class="text-lg font-semibold text-gray-900 dark:text-white">{{ faq.question }}</h3>
              <span class="ml-6 flex-shrink-0">
                <svg 
                  class="h-6 w-6 transform transition-transform duration-200 text-gray-900 dark:text-white"
                  :class="{ 'rotate-180': faq.isOpen }"
                  fill="none" 
                  viewBox="0 0 24 24" 
                  stroke="currentColor"
                >
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                </svg>
              </span>
            </button>
            <div 
              v-show="faq.isOpen"
              class="mt-2 text-gray-900 dark:text-gray-100"
            >
              <p>{{ faq.answer }}</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'

definePageMeta({
  layout: 'default'
})

const faqs = ref([
  {
    question: "How do I start tracking a trip?",
    answer: "Simply open the app and tap the 'Start Trip' button on the home screen. The app will begin tracking your journey automatically.",
    isOpen: false
  },
  {
    question: "What types of transportation can I track?",
    answer: "You can track walking, cycling, and driving trips. Each type has its own tracking features optimized for that mode of transport.",
    isOpen: false
  },
  {
    question: "How do I add expenses or earnings to a trip?",
    answer: "When you end a trip, you'll be prompted to enter any expenses or earnings associated with the journey. You can specify the amount and whether it was money spent or earned.",
    isOpen: false
  },
  {
    question: "Can I view my past trips?",
    answer: "Yes! All your past trips are available in the 'Past Trips' tab, where you can see details like date, transportation type, and any associated expenses or earnings.",
    isOpen: false
  },
  {
    question: "Is my data secure?",
    answer: "Yes, we take data security seriously. All your trip data is encrypted and stored securely. We only collect the information necessary to provide the service.",
    isOpen: false
  },
  {
    question: "How do I update my profile settings?",
    answer: "You can access your profile settings by tapping the 'Settings' tab in the bottom navigation. From there, you can update your preferences and account information.",
    isOpen: false
  }
])

const toggleFaq = (index) => {
  faqs.value[index].isOpen = !faqs.value[index].isOpen
}
</script> 