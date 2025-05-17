<template>
  <NuxtLayout>
    <NuxtPage />
  </NuxtLayout>
</template>

<script setup>
import { onMounted } from 'vue';

onMounted(() => {
  document.addEventListener('deviceready', function() {
    document.getElementById('requestTrackingBtn').addEventListener('click', function() {
      if (window.plugins && window.plugins.idfa) {
        window.plugins.idfa.requestPermission(function(result) {
          if (result === 'authorized') {
            console.log('Tracking authorized');
          } else {
            console.log('Tracking not authorized:', result);
          }
        });
      }
    });
  }, false);
});
</script>

