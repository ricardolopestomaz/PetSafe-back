-- ========================================
-- 1. USUARIOS (ligado ao Supabase Auth)
-- ========================================
create table usuarios (
  id uuid primary key references auth.users(id) on delete cascade,
  nome text not null,
  email text unique,
  telefone text,
  endereco text,
  foto_perfil_url text,
  criado_em timestamptz default now()
);
-- Obs: sem senha_hash. O Supabase Auth já cuida do login/senha.

-- ========================================
-- 2. PLANOS (com as features como colunas booleanas)
-- ========================================
create table planos (
  id uuid primary key default gen_random_uuid(),
  nome text not null,
  preco_mensal numeric(10,2) not null,
  preco_anual numeric(10,2) not null,
  max_pets int not null,
  alerta_instantaneo boolean default false,
  carteira_vacina boolean default false,
  historico_medico boolean default false,
  video_tutor boolean default false,
  mapa_completo boolean default false
);

-- ========================================
-- 3. ASSINATURAS
-- ========================================
create table assinaturas (
  id uuid primary key default gen_random_uuid(),
  usuario_id uuid not null references usuarios(id) on delete cascade,
  plano_id uuid not null references planos(id),
  status text not null default 'ativa',
  data_inicio timestamptz default now(),
  data_fim timestamptz
);

-- ========================================
-- 4. PAGAMENTOS
-- ========================================
create table pagamentos (
  id uuid primary key default gen_random_uuid(),
  assinatura_id uuid not null references assinaturas(id) on delete cascade,
  valor numeric(10,2) not null,
  data_pagamento timestamptz default now(),
  status text not null default 'pendente',  -- pendente, pago, recusado, estornado
  metodo text                                -- pix, cartao, boleto...
);

-- ========================================
-- 5. PETS
-- ========================================
create table pets (
  id uuid primary key default gen_random_uuid(),
  tutor_id uuid not null references usuarios(id) on delete cascade, -- tutor principal
  nome text not null,
  especie text,
  raca text,
  data_nascimento date,
  foto_url text,
  video_url text,
  observacoes text,
  criado_em timestamptz default now()
);

-- ========================================
-- 6. PET_TUTORES (permite mais de um tutor por pet)
-- ========================================
create table pet_tutores (
  id uuid primary key default gen_random_uuid(),
  pet_id uuid not null references pets(id) on delete cascade,
  usuario_id uuid not null references usuarios(id) on delete cascade,
  papel text not null default 'cuidador',  -- ex: 'dono', 'cuidador', 'veterinario'
  unique (pet_id, usuario_id)
);

-- ========================================
-- 7. CONTATOS_EMERGENCIA
-- ========================================
create table contatos_emergencia (
  id uuid primary key default gen_random_uuid(),
  pet_id uuid not null references pets(id) on delete cascade,
  nome text not null,
  telefone text not null,
  prioridade int default 1
);

-- ========================================
-- 8. VACINAS
-- ========================================
create table vacinas (
  id uuid primary key default gen_random_uuid(),
  pet_id uuid not null references pets(id) on delete cascade,
  nome_vacina text not null,
  data_aplicacao date,
  proxima_dose date,
  veterinario text,
  comprovante_url text
);

-- ========================================
-- 9. HISTORICO_MEDICO
-- ========================================
create table historico_medico (
  id uuid primary key default gen_random_uuid(),
  pet_id uuid not null references pets(id) on delete cascade,
  tipo text,          -- consulta, cirurgia, exame...
  descricao text,
  data date,
  clinica text,
  anexo_url text
);

-- ========================================
-- 10. MEDALHAS
-- ========================================
create table medalhas (
  id uuid primary key default gen_random_uuid(),
  pet_id uuid references pets(id) on delete set null,
  codigo_qr text unique not null,
  nft_token_id text,
  contract_address text,
  wallet_address text,
  blockchain text,
  status text not null default 'ativa',
  data_ativacao timestamptz default now()
);

-- ========================================
-- 11. LEITURAS
-- ========================================
create table leituras (
  id uuid primary key default gen_random_uuid(),
  medalha_id uuid not null references medalhas(id) on delete cascade,
  latitude double precision,
  longitude double precision,
  endereco_aprox text,
  encontrado_nome text,
  encontrado_telefone text,
  mensagem text,
  foto_url text,
  ip_address text,
  criado_em timestamptz default now()
);

-- ========================================
-- 12. NOTIFICACOES
-- ========================================
create table notificacoes (
  id uuid primary key default gen_random_uuid(),
  leitura_id uuid not null references leituras(id) on delete cascade,
  usuario_id uuid not null references usuarios(id) on delete cascade,
  canal text not null,               -- whatsapp, email, push...
  status_envio text not null default 'pendente',
  enviado_em timestamptz
);

-- ========================================
-- FUNÇÃO AUXILIAR: usuário é tutor do pet? (dono principal OU em pet_tutores)
-- ========================================
create or replace function is_tutor_do_pet(check_pet_id uuid)
returns boolean as $$
  select exists (
    select 1 from pets where id = check_pet_id and tutor_id = auth.uid()
    union
    select 1 from pet_tutores where pet_id = check_pet_id and usuario_id = auth.uid()
  );
$$ language sql security definer stable;

-- ========================================
-- RLS (Row Level Security)
-- ========================================
alter table usuarios enable row level security;
alter table planos enable row level security;
alter table assinaturas enable row level security;
alter table pagamentos enable row level security;
alter table pets enable row level security;
alter table pet_tutores enable row level security;
alter table contatos_emergencia enable row level security;
alter table vacinas enable row level security;
alter table historico_medico enable row level security;
alter table medalhas enable row level security;
alter table leituras enable row level security;
alter table notificacoes enable row level security;

-- USUARIOS: só vê/edita o próprio registro
create policy "usuario ve proprio registro"
  on usuarios for select using (auth.uid() = id);
create policy "usuario edita proprio registro"
  on usuarios for update using (auth.uid() = id);
create policy "usuario cria proprio registro"
  on usuarios for insert with check (auth.uid() = id);

-- PLANOS: catálogo público
create policy "qualquer um ve os planos"
  on planos for select using (true);

-- ASSINATURAS: só o próprio usuário
create policy "usuario ve suas assinaturas"
  on assinaturas for select using (auth.uid() = usuario_id);
create policy "usuario gerencia suas assinaturas"
  on assinaturas for all using (auth.uid() = usuario_id);

-- PAGAMENTOS: só o dono da assinatura vê seus pagamentos
create policy "usuario ve seus pagamentos"
  on pagamentos for select using (
    auth.uid() = (select usuario_id from assinaturas where id = assinatura_id)
  );

-- PETS: dono principal ou qualquer tutor vinculado pode ver/gerenciar
create policy "tutores veem o pet"
  on pets for select using (is_tutor_do_pet(id));
create policy "tutor principal gerencia o pet"
  on pets for all using (auth.uid() = tutor_id);

-- PET_TUTORES: tutores do pet podem ver a lista; só o tutor principal adiciona/remove
create policy "tutores veem vinculo"
  on pet_tutores for select using (is_tutor_do_pet(pet_id));
create policy "tutor principal gerencia vinculos"
  on pet_tutores for all
  using (auth.uid() = (select tutor_id from pets where id = pet_id));

-- CONTATOS_EMERGENCIA: leitura pública (achou o pet), gestão só de tutores
create policy "qualquer um ve contato de emergencia"
  on contatos_emergencia for select using (true);
create policy "tutores gerenciam contatos"
  on contatos_emergencia for all using (is_tutor_do_pet(pet_id));

-- VACINAS: só tutores do pet
create policy "tutores veem vacinas"
  on vacinas for select using (is_tutor_do_pet(pet_id));
create policy "tutores gerenciam vacinas"
  on vacinas for all using (is_tutor_do_pet(pet_id));

-- HISTORICO_MEDICO: só tutores do pet
create policy "tutores veem historico"
  on historico_medico for select using (is_tutor_do_pet(pet_id));
create policy "tutores gerenciam historico"
  on historico_medico for all using (is_tutor_do_pet(pet_id));

-- MEDALHAS: leitura pública (para escanear), gestão só de tutores
create policy "qualquer um ve medalha"
  on medalhas for select using (true);
create policy "tutores gerenciam medalha"
  on medalhas for all using (is_tutor_do_pet(pet_id));

-- LEITURAS: qualquer um pode registrar (quem escaneou), só tutores veem histórico
create policy "qualquer um registra leitura"
  on leituras for insert with check (true);
create policy "tutores veem leituras"
  on leituras for select using (
    is_tutor_do_pet((select pet_id from medalhas where id = medalha_id))
  );

-- NOTIFICACOES: só o próprio usuário vê as notificações dele
create policy "usuario ve suas notificacoes"
  on notificacoes for select using (auth.uid() = usuario_id);