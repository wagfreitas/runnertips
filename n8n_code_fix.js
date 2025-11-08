// Código corrigido para o node "Code (parse agent output)" no n8n
// Substitua o código atual por este:

let raw = $input.first().json.output;

// Tenta fazer parse do JSON
let data;
try {
  // Se já é um objeto, usa diretamente
  if (typeof raw === 'object' && raw !== null) {
    data = raw;
  } 
  // Se é string, tenta fazer parse
  else if (typeof raw === 'string') {
    // Remove markdown code blocks se existirem
    let cleaned = raw.trim();
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.replace(/^```json\s*/, '').replace(/\s*```$/, '');
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.replace(/^```\s*/, '').replace(/\s*```$/, '');
    }
    
    data = JSON.parse(cleaned);
  } 
  else {
    throw new Error('Formato não suportado');
  }
  
  // Valida se tem pelo menos query_text ou conclusion
  if (!data.query_text && !data.conclusion) {
    throw new Error('Resposta inválida: falta query_text ou conclusion');
  }
  
  return { json: data };
  
} catch (error) {
  console.error('Erro ao fazer parse:', error);
  console.error('Raw data:', raw);
  
  // Retorna erro estruturado
  return { 
    json: { 
      error: 'Erro ao processar resposta do agente',
      error_message: error.message,
      raw_output: typeof raw === 'string' ? raw.substring(0, 500) : String(raw)
    } 
  };
}

