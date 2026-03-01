-- ClapRun Supabase 테이블 설정
-- Supabase Dashboard → SQL Editor에서 실행하세요

-- 1. 유저 프로필
create table if not exists profiles (
  id uuid references auth.users on delete cascade primary key,
  nickname text not null,
  avatar text default '🦊',
  at_code text unique,
  joined_at timestamptz default now()
);

-- 2. 런 기록
create table if not exists runs (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references profiles(id) on delete cascade,
  distance float not null,
  pace text,
  time text,
  cal int default 0,
  created_at timestamptz default now()
);

-- 3. Clap
create table if not exists claps (
  id uuid default gen_random_uuid() primary key,
  from_user uuid references profiles(id) on delete cascade,
  to_user uuid references profiles(id) on delete cascade,
  run_id uuid references runs(id) on delete set null,
  created_at timestamptz default now()
);

-- 4. 인증샷
create table if not exists shots (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references profiles(id) on delete cascade,
  image_url text,
  distance float,
  created_at timestamptz default now()
);

-- RLS (Row Level Security) 활성화
alter table profiles enable row level security;
alter table runs enable row level security;
alter table claps enable row level security;
alter table shots enable row level security;

-- 프로필: 누구나 읽기, 본인만 수정
create policy "프로필 읽기" on profiles for select using (true);
create policy "프로필 생성" on profiles for insert with check (auth.uid() = id);
create policy "프로필 수정" on profiles for update using (auth.uid() = id);

-- 런: 누구나 읽기, 본인만 생성
create policy "런 읽기" on runs for select using (true);
create policy "런 생성" on runs for insert with check (auth.uid() = user_id);

-- Clap: 누구나 읽기, 로그인 유저 생성
create policy "Clap 읽기" on claps for select using (true);
create policy "Clap 생성" on claps for insert with check (auth.uid() = from_user);

-- 인증샷: 누구나 읽기, 본인만 생성/삭제
create policy "샷 읽기" on shots for select using (true);
create policy "샷 생성" on shots for insert with check (auth.uid() = user_id);
create policy "샷 삭제" on shots for delete using (auth.uid() = user_id);
