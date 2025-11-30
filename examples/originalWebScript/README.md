<script>
  (function() {
    var script = document.createElement("script");
    script.src = "https://cdn.qc.founder-os.ai/script/v2/tracker.umd.js";
    script.onload = function() {
      window.Tracker.init("YOUR_BRAND_ID", { x_api_key: "YOUR_API_KEY", enable_widget: true });
      window.Tracker.identify("USER_ID", { name: "John Doe", email: "abc@gmail.com" });
      window.Tracker.track("BUTTON_CLICK", { button: "purchase", value: 100 });
      window.Tracker.setMetadata({ plan: "premium" });
    };
    document.head.appendChild(script);
  })();
</script>
