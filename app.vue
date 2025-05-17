<template>
  <NuxtLayout>
    <NuxtPage />
  </NuxtLayout>
</template>

<script setup>
import { onMounted } from 'vue';

onMounted(() => {
  document.addEventListener('deviceready', function() {
    if (window.plugins && window.plugins.idfa) {
      window.plugins.idfa.requestPermission(function(result) {
        if (result === 'authorized') {
          // Tracking allowed
          console.log('Tracking authorized');
        } else {
          // Tracking not allowed
          console.log('Tracking not authorized:', result);
        }
      });
    }
  }, false);
});
</script>

