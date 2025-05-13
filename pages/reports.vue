<template>
  <div class="min-h-screen bg-gray-100 dark:bg-gray-900 py-8">
    <div class="max-w-4xl mx-auto px-4">
      <h1 class="text-2xl font-bold mb-6 text-gray-900 dark:text-white">Reports</h1>
      <div class="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6 mb-8">
        <div class="flex flex-wrap gap-4 mb-6 items-center">
          <label class="block text-gray-700 dark:text-gray-300">
            <span>Month</span>
            <select v-model="selectedMonth" class="ml-2 px-2 py-1 rounded border border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-white">
              <option v-for="(month, idx) in months" :key="idx" :value="idx+1">{{ month }}</option>
            </select>
          </label>
          <label class="block text-gray-700 dark:text-gray-300">
            <span>Year</span>
            <select v-model="selectedYear" class="ml-2 px-2 py-1 rounded border border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-white">
              <option v-for="year in years" :key="year" :value="year">{{ year }}</option>
            </select>
          </label>
        </div>
        <!-- Tabs -->
        <div class="flex justify-center mb-6">
          <button
            v-for="tab in tabs"
            :key="tab.value"
            @click="activeTab = tab.value"
            :class="[
              'px-6 py-2 rounded-t-lg font-semibold focus:outline-none transition',
              activeTab === tab.value
                ? 'bg-[#d8c856] text-[#6c6217] shadow'
                : 'bg-gray-100 dark:bg-gray-700 text-gray-600 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-600'
            ]"
            style="margin-right: 2px;"
          >
            {{ tab.label }}
          </button>
        </div>
        <!-- Tab Panels -->
        <div v-if="activeTab === 'chart'">
          <div id="amchart-reports" class="bg-white rounded-lg shadow-lg p-6" style="height: 400px;"></div>
        </div>
        <div v-else-if="activeTab === 'earnings'">
          <div class="overflow-x-auto bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6">
            <h2 class="text-lg font-semibold mb-2 text-gray-900 dark:text-white">Daily Earnings</h2>
            <table class="min-w-full bg-white dark:bg-gray-800 rounded shadow overflow-hidden">
              <thead>
                <tr>
                  <th class="px-4 py-2 text-left text-gray-700 dark:text-gray-300">Day</th>
                  <th class="px-4 py-2 text-left text-green-700 dark:text-green-400">Earnings</th>
                  <th class="px-4 py-2 text-left text-gray-700 dark:text-gray-300">Trips</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="row in chartData" :key="'earn-' + row.day">
                  <td class="px-4 py-2 text-gray-900 dark:text-white">{{ row.day }}</td>
                  <td class="px-4 py-2 text-green-900 dark:text-green-300">{{ row.earning.toFixed(2) }}</td>
                  <td class="px-4 py-2 text-gray-900 dark:text-white">{{ row.earningTrips }}</td>
                </tr>
              </tbody>
              <tfoot>
                <tr class="bg-gray-50 dark:bg-gray-700">
                  <td class="px-4 py-2 font-bold text-gray-900 dark:text-white">Total</td>
                  <td class="px-4 py-2 text-green-900 dark:text-green-300 font-bold">{{ earningsTotal.toFixed(2) }}</td>
                  <td class="px-4 py-2 text-gray-900 dark:text-white font-bold">{{ earningsTripsTotal }}</td>
                </tr>
              </tfoot>
            </table>
          </div>
        </div>
        <div v-else-if="activeTab === 'spending'">
          <div class="overflow-x-auto bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6">
            <h2 class="text-lg font-semibold mb-2 text-gray-900 dark:text-white">Daily Spending</h2>
            <table class="min-w-full bg-white dark:bg-gray-800 rounded shadow overflow-hidden">
              <thead>
                <tr>
                  <th class="px-4 py-2 text-left text-gray-700 dark:text-gray-300">Day</th>
                  <th class="px-4 py-2 text-left text-red-700 dark:text-red-400">Spending</th>
                  <th class="px-4 py-2 text-left text-gray-700 dark:text-gray-300">Trips</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="row in chartData" :key="'spend-' + row.day">
                  <td class="px-4 py-2 text-gray-900 dark:text-white">{{ row.day }}</td>
                  <td class="px-4 py-2 text-red-900 dark:text-red-300">{{ row.spending.toFixed(2) }}</td>
                  <td class="px-4 py-2 text-gray-900 dark:text-white">{{ row.spendingTrips }}</td>
                </tr>
              </tbody>
              <tfoot>
                <tr class="bg-gray-50 dark:bg-gray-700">
                  <td class="px-4 py-2 font-bold text-gray-900 dark:text-white">Total</td>
                  <td class="px-4 py-2 text-red-900 dark:text-red-300 font-bold">{{ spendingTotal.toFixed(2) }}</td>
                  <td class="px-4 py-2 text-gray-900 dark:text-white font-bold">{{ spendingTripsTotal }}</td>
                </tr>
              </tfoot>
            </table>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch, computed } from 'vue'
import * as am5 from '@amcharts/amcharts5'
import * as am5xy from '@amcharts/amcharts5/xy'
import am5themes_Animated from '@amcharts/amcharts5/themes/Animated'
import { useSupabaseClient, useSupabaseUser } from '#imports'
import { useDarkMode } from '~/composables/useDarkMode'

const client = useSupabaseClient()
const user = useSupabaseUser()
const { isDarkMode } = useDarkMode()

const now = new Date()
const months = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December'
]
const selectedMonth = ref(now.getMonth() + 1)
const selectedYear = ref(now.getFullYear())
const years = ref([now.getFullYear(), now.getFullYear() - 1])
let chart = null
const chartData = ref([])

const earningsTotal = computed(() => chartData.value.reduce((sum, row) => sum + row.earning, 0))
const spendingTotal = computed(() => chartData.value.reduce((sum, row) => sum + row.spending, 0))

const fetchData = async () => {
  if (!user.value) return []
  const start = new Date(selectedYear.value, selectedMonth.value - 1, 1)
  const end = new Date(selectedYear.value, selectedMonth.value, 0, 23, 59, 59, 999)
  const { data, error } = await client
    .from('ridez_rides')
    .select('created_at, amount, transaction_type')
    .eq('user_id', user.value.id)
    .gte('created_at', start.toISOString())
    .lte('created_at', end.toISOString())

  if (error) {
    console.error('Error fetching report data:', error)
    return []
  }

  // Aggregate by day
  const daysInMonth = new Date(selectedYear.value, selectedMonth.value, 0).getDate()
  const result = Array.from({ length: daysInMonth }, (_, i) => ({
    day: i + 1,
    spending: 0,
    earning: 0,
    spendingTrips: 0,
    earningTrips: 0
  }))
  for (const row of data) {
    const date = new Date(row.created_at)
    const day = date.getDate()
    if (row.transaction_type === 'spending') {
      result[day - 1].spending += Number(row.amount) || 0
      result[day - 1].spendingTrips += 1
    } else if (row.transaction_type === 'earning') {
      result[day - 1].earning += Number(row.amount) || 0
      result[day - 1].earningTrips += 1
    }
  }
  return result
}

const renderChart = async () => {
  chartData.value = await fetchData()
  if (!chart) {
    let root = am5.Root.new('amchart-reports')

    // Custom theme for dark mode
    if (isDarkMode.value) {
      root.setThemes([
        am5themes_Animated.new(root),
        am5.Theme.new(root, {
          setup: function(target) {
            if (target instanceof am5.Label) {
              target.setAll({ fill: am5.color(0xF3F4F6) }) // Tailwind gray-100
            }
            if (target instanceof am5.AxisRenderer) {
              target.setAll({ stroke: am5.color(0x6B7280) }) // Tailwind gray-500
            }
            if (target instanceof am5.Grid) {
              target.setAll({ stroke: am5.color(0x374151) }) // Tailwind gray-700
            }
            if (target instanceof am5.Tooltip) {
              target.setAll({ fill: am5.color(0x111827), labelText: "{valueY}" }) // Tailwind gray-900
            }
            if (target instanceof am5.Container) {
              target.setAll({ background: am5.color(0x1F2937) }) // Tailwind gray-800
            }
          }
        })
      ])
    } else {
      root.setThemes([am5themes_Animated.new(root)])
    }

    chart = root.container.children.push(
      am5xy.XYChart.new(root, {
        panX: false,
        panY: false,
        wheelX: 'none',
        wheelY: 'none',
        layout: root.verticalLayout
      })
    )
    let xAxis = chart.xAxes.push(
      am5xy.CategoryAxis.new(root, {
        categoryField: 'day',
        renderer: am5xy.AxisRendererX.new(root, {}),
        tooltip: am5.Tooltip.new(root, {})
      })
    )
    xAxis.data.setAll(chartData.value)
    let yAxis = chart.yAxes.push(
      am5xy.ValueAxis.new(root, {
        renderer: am5xy.AxisRendererY.new(root, {})
      })
    )
    let spendingSeries = chart.series.push(
      am5xy.ColumnSeries.new(root, {
        name: 'Spending',
        xAxis: xAxis,
        yAxis: yAxis,
        valueYField: 'spending',
        categoryXField: 'day',
        fill: am5.color(0xEF4444),
        stroke: am5.color(0xEF4444)
      })
    )
    spendingSeries.data.setAll(chartData.value)
    let earningSeries = chart.series.push(
      am5xy.ColumnSeries.new(root, {
        name: 'Earning',
        xAxis: xAxis,
        yAxis: yAxis,
        valueYField: 'earning',
        categoryXField: 'day',
        fill: am5.color(0x22C55E),
        stroke: am5.color(0x22C55E)
      })
    )
    earningSeries.data.setAll(chartData.value)
    chart.set('cursor', am5xy.XYCursor.new(root, {}))
    chart.appear(1000, 100)
  } else {
    // Update chart data
    chart.xAxes.getIndex(0).data.setAll(chartData.value)
    chart.series.getIndex(0).data.setAll(chartData.value)
    chart.series.getIndex(1).data.setAll(chartData.value)
  }
}

const tabs = [
  { label: 'Chart', value: 'chart' },
  { label: 'Daily Earnings', value: 'earnings' },
  { label: 'Daily Spendings', value: 'spending' }
]
const activeTab = ref('chart')

onMounted(() => {
  renderChart()
})

watch([selectedMonth, selectedYear], () => {
  renderChart()
})
</script>

<style scoped>
#amchart-reports {
  min-height: 400px;
}
</style> 