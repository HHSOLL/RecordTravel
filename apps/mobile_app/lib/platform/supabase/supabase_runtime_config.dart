class SupabaseRuntimeConfig {
  const SupabaseRuntimeConfig({required this.url, required this.anonKey});

  final String url;
  final String anonKey;

  bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;

  static const fromEnvironment = SupabaseRuntimeConfig(
    url: String.fromEnvironment('SUPABASE_URL', defaultValue: ''),
    anonKey: String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: ''),
  );
}
